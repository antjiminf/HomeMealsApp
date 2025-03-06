import SwiftUI

enum MethodType {
    case UPDATE
    case CREATE
}

struct RecipeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @Environment(RecipesVM.self) private var recipesVm
    @State var addRecipeVm: AddRecipeVM
    @State var showIngredientsForm = false
    let title: String
    let method: MethodType
    var onUpdate: (() -> Void)? = nil
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("") {
                    CustomTextField(label: "Recipe Name",
                                    value: $addRecipeVm.name,
                                    isError: $addRecipeVm.error,
                                    hint: "Name of the recipe",
                                    validation: addRecipeVm.validationName,
                                    initial: false)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .description
                    }
                    CustomTextField(label: "Description",
                                    value: $addRecipeVm.description,
                                    isError: $addRecipeVm.error,
                                    hint: "Description",
                                    validation: addRecipeVm.validationDescription,
                                    initial: false,
                                    lines: 3)
                    .focused($focusedField, equals: .description)
                    .onSubmit {
                        focusedField = .time
                    }
                    MinutesStepper( label: "Recipe time",
                                    value: $addRecipeVm.time,
                                    initial: false,
                                    hint: "Recipe time of preparation",
                                    isError: $addRecipeVm.error,
                                    validation: addRecipeVm.validationTime)
                    .focused($focusedField, equals: .time)
                    .submitLabel(.next)
                    .onSubmit {
                        if !addRecipeVm.ingredients.isEmpty {
                            focusedField = .ingredientQuantity(0)
                        } else {
                            focusedField = .guideStep(0)
                        }
                    }
                    Toggle(addRecipeVm.isPublic ? "Public recipe" : "Private recipe", isOn: $addRecipeVm.isPublic)
                        .bold()
                }
                
                Section("Details") {
                    IngredientsSelectedList(focusedField: $focusedField,
                                            showIngredientsForm: $showIngredientsForm,
                                            ingredients: $addRecipeVm.ingredients,
                                            isError: $addRecipeVm.error,
                                            //                                            removeIngredient: addRecipeVm.removeIngredient,
                                            validation: addRecipeVm.validateIngredients)
                    
                    GuideField(focusedField: $focusedField,
                               guide: $addRecipeVm.guide,
                               isError: $addRecipeVm.error,
                               validation: addRecipeVm.validationGuide,
                               addGuideStep: addRecipeVm.addGuideStep,
                               removeLastStep: addRecipeVm.removeLastStep)
                    
                }
                Section("Allergens") {
                    AllergensSelector(
                        allergens: addRecipeVm.allergens,
                        showAllergens: $addRecipeVm.showAllergens,
                        toggleAllergen: addRecipeVm.toggleAllergenSelection,
                        isAllergenSelected: addRecipeVm.isAllergenAdded)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            if let recipe = addRecipeVm.createRecipeDto() {
                                
                                if method == .CREATE {
                                    await recipesVm.addRecipe(recipe)
                                } else if method == .UPDATE,
                                          let id = addRecipeVm.id {
                                    await recipesVm.updateRecipe(id: id, updated: recipe)
                                }
                                
                                if !recipesVm.hasError {
                                    onUpdate?()
                                    dismiss()
                                } else {
                                    addRecipeVm.showAlert = true
                                }
                            }
                        }
                    } label: {
                        Text("Save")
                    }
                    .disabled(addRecipeVm.error)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    
                    Button {
                        focusedField?.previous()
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    Button {
                        if focusedField == .guideStep(addRecipeVm.guide.count - 1) {
                            focusedField?.next(totalSteps: addRecipeVm.guide.count,
                                               addStep: addRecipeVm.addGuideStep)
                        } else if case .ingredientQuantity(_) = focusedField {
                            focusedField?.next(totalIngredients: addRecipeVm.ingredients.count)
                        } else if focusedField == .time {
                            focusedField?.next(totalIngredients: addRecipeVm.ingredients.count)
                        } else {
                            focusedField?.next()
                        }
                    } label: {
                        if focusedField == .guideStep(addRecipeVm.guide.count - 1) {
                            Image(systemName: "plus")
                        } else {
                            Image(systemName: "chevron.down")
                        }
                    }
                    Spacer()
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down.fill")
                    }
                    
                }
            }
            .fullScreenCover(isPresented: $showIngredientsForm) {
                IngredientsSelector(
                    selectorVM: IngredientSelectorVM(),
                    selectedIngredients: $addRecipeVm.ingredients,
                    title: "Select Ingredients")
            }
            .alert("Error", isPresented: $addRecipeVm.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let errorMessage = recipesVm.errorMessage {
                    Text(errorMessage)
                }
            }
            .onTapGesture {
                if let _ = focusedField {
                    focusedField = nil
                }
            }
            .onAppear {
                focusedField = .name
            }
        }
    }
}

extension RecipeFormView {
    enum Field: Hashable {
        case name, description, time
        case ingredientQuantity(Int)
        case guideStep(Int)
        
        mutating func next(totalIngredients: Int = 0, totalSteps: Int = 3, addStep: () -> Void = {}) {
            switch self {
            case .name:
                self = .description
            case .description:
                self = .time
            case .time:
                if totalIngredients == 0 {
                    self = .guideStep(0)
                } else {
                    self = .ingredientQuantity(0)
                }
            case .ingredientQuantity(let index):
                if index < totalIngredients - 1 {
                    self = .ingredientQuantity(index + 1)
                } else {
                    self = .guideStep(0)
                }
            case .guideStep(let index):
                if index < totalSteps - 1 {
                    self = .guideStep(index + 1)
                } else {
                    addStep()
                    self = .guideStep(index + 1)
                }
            }
        }
        
        mutating func previous() {
            switch self {
            case .name:
                self = .guideStep(0)
            case .description:
                self = .name
            case .time:
                self = .description
            case .ingredientQuantity(let index):
                if index > 0 {
                    self = .ingredientQuantity(index - 1)
                } else {
                    self = .time
                }
            case .guideStep(let index):
                if index > 0 {
                    self = .guideStep(index - 1)
                } else {
                    self = .time
                }
            }
        }
    }
}


#Preview {
    RecipeFormView.preview
}
