import SwiftUI

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RecipesVM.self) private var recipesVm
    @State var addRecipeVm = AddRecipeVM()
    @State var showIngredientsForm = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("") {
                    CustomTextField(
                        label: "Recipe Name",
                        value: $addRecipeVm.name,
                        isError: $addRecipeVm.error,
                        hint: "Name of the recipe",
                        validation: addRecipeVm.validationName,
                        initial: false)
                    CustomTextField(
                        label: "Description",
                        value: $addRecipeVm.description,
                        isError: $addRecipeVm.error,
                        hint: "Description",
                        validation: addRecipeVm.validationDescription,
                        initial: false,
                        lines: 3)
                    CustomStepper(
                        label: "Recipe time",
                        value: $addRecipeVm.time,
                        initial: false,
                        hint: "Recipe time of preparation",
                        isError: $addRecipeVm.error,
                        validation: addRecipeVm.validationTime)
                    Toggle(addRecipeVm.isPublic ? "Private recipe" : "Public recipe", isOn: $addRecipeVm.isPublic)
                        .bold()
                }
                Section("Details") {
                    //TODO: Validacion / Accesibilidad
                    IngredientsSelectedView(showIngredientsForm: $showIngredientsForm, ingredients: $addRecipeVm.ingredients)
                    
                    VStack(alignment: .leading) {
                        Text("Guide")
                            .bold()
                        ForEach(0..<addRecipeVm.guide.count, id: \.self) { index in
                            TextField("Step \(index + 1)", text: $addRecipeVm.guide[index], axis: .vertical)
                                .lineLimit(2, reservesSpace: true)
                            //                                .overlay {
                            //                                    RoundedRectangle(cornerRadius: 10)
                            //                                        .stroke(lineWidth: 2.0)
                            //                                        .fill(.red)
                            //                                        .padding(2)
                            //                                       .opacity( ? 1.0 : 0.0)
                            //                                }
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                }
                        }
                        
                        Button {
                            addRecipeVm.addGuideStep()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add step")
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .contentShape(Rectangle())
                        .padding(.top, 5)
                    }
                    .padding(.bottom)
                    
                }
                AllergensSelector(
                    allergens: addRecipeVm.allergens,
                    showAllergens: $addRecipeVm.showAllergens,
                    toggleAllergen: addRecipeVm.toggleAllergenSelection,
                    isAllergenSelected: addRecipeVm.isAllergenAdded)
            }
            .navigationTitle("Create Recipe")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await addRecipeVm.addRecipe()
                            dismiss()
                        }
                    } label: {
                        Text("Add")
                    }
                }
            }
            .fullScreenCover(isPresented: $showIngredientsForm) {
                IngredientsSelector(selectorVM: IngredientSelectorVM(), selectedIngredients: $addRecipeVm.ingredients)
            }
        }
    }
}

#Preview {
    AddRecipeView.preview
}

struct CustomStepper: View {
    let label: String
    @Binding var value: Int
    var initial = true
    var hint: String
    @Binding var isError: Bool
    let validation: (Int) -> String?
    
    @State private var error = false
    @State private var errorMsg = ""
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Time")
                .bold()
            Stepper(value: $value, in: 3...240, step: 1) {
                
                HStack {
                    Text("In minutes:")
                        .bold()
                    TextField("3", value: $value, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }
            }
            .padding()
            .onChange(of: value, initial: initial) {
                if let message = validation(value) {
                    error = true
                    errorMsg = message
                } else {
                    error = false
                    errorMsg = ""
                }
                isError = error
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2.0)
                    .fill(.red)
                    .padding(2)
                    .opacity(error ? 1.0 : 0.0)
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemBackground))
            }
            Text("\(label.capitalized) \(errorMsg).")
                .font(.caption2)
                .foregroundStyle(.red)
                .bold()
                .padding(.horizontal, 10)
                .opacity(error ? 1.0 : 0.0)
                .accessibilityLabel(Text("\(label) error message."))
                .accessibilityHint(Text("This is an error validation message for the field \(label). Fix the error to continue."))
        }
    }
}

struct IngredientsSelectedView: View {
    @Binding var showIngredientsForm: Bool
    @Binding var ingredients: [SelectionIngredient]
    
    var body: some View {
        VStack {
            HStack{
                Text("Ingredients")
                    .bold()
                Spacer()
                Button {
                    showIngredientsForm.toggle()
                } label: {
                    Text("Edit")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.bottom)
            if ingredients.isEmpty {
                HStack {
                    Text("No ingredients selected")
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                }
                .foregroundStyle(.secondary)
            }
            else {
                ForEach(ingredients, id: \.self) { ing in
                    HStack{
                        
                        Text(ing.name)
                        Spacer()
                        switch ing.unit {
                        case .units:
                            Text("\(ing.quantity, specifier: "%.0f") units")
                        case .volume:
                            Text("\(ing.quantity, specifier: "%.2f") L")
                        case .weight:
                            Text("\(ing.quantity, specifier: "%.2f") g")
                        }
                    }
                }
            }
        }
        .padding(.bottom)
    }
}
