import SwiftUI

struct IngredientsSelector: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(IngredientsVM.self) var ingredientsVM
    @State var selectorVM: IngredientSelectorVM
    @Binding var selectedIngredients: [SelectionIngredient]
    @State var detent: PresentationDetent = .fraction(0.5)
    
    var body: some View {
        @Bindable var ingredientsBinding = ingredientsVM
        NavigationView {
            Form {
                TextField("Search...", text: $ingredientsBinding.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Group {
                    if !ingredientsVM.filteredIngredients.isEmpty {
                        ForEach(ingredientsVM.ingredientsByCategory.keys.sorted(), id: \.self) { category in
                            Section(header: Text(category.rawValue.capitalized)) {
                                ForEach(ingredientsVM.ingredientsByCategory[category]?.sorted(by: {$0.name < $1.name}) ?? [], id: \.self) { ingredient in
                                    
                                    IngredientQuantity(
                                        ingredientName: ingredient.name,
                                        quantity: Binding(
                                            get: { selectorVM.quantityForIngredient(ingredient) },
                                            set: { newQuantity in
                                                selectorVM.updateIngredientSelection(ingredient: ingredient, quantity: newQuantity)}
                                        ),
                                        unit: ingredient.unit)
                                }
                            }
                        }
                    } else {
                        Section("") {
                            ContentUnavailableView(
                                "No coincidences",
                                systemImage: "exclamationmark.magnifyingglass",
                                description: Text("No ingredients found containing \"\(ingredientsVM.searchText)\""))
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Edit") {
                        selectedIngredients = selectorVM.saveIngredients()
                        ingredientsBinding.searchText = ""
                        dismiss()
                    }
                    .accessibilityHint(Text("This button will confirm any change done"))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        ingredientsBinding.searchText = ""
                        dismiss()
                    }
                    .accessibilityHint(Text("Cancels the ingredients selection"))
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Show Selected") {
                        selectorVM.showSelectedIngredients.toggle()
                    }
                    .bold()
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .accessibilityHint(Text("Shows the list of ingredients selected"))
                }
            }
            .navigationTitle("Select Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectorVM.loadInitialSelectedIngredients(selectedIngredients)
            }
            .sheet(isPresented: $selectorVM.showSelectedIngredients) {
                List(selectorVM.sortedIngredients) { i in
                    HStack {
                        Text(i.name)
                        Spacer()
                        switch i.unit {
                            case .units:
                            Text("\(i.quantity, specifier: "%.0f") units")
                            case .volume:
                                Text("\(i.quantity, specifier: "%.2f") L")
                            case .weight:
                                Text("\(i.quantity, specifier: "%.2f") g")
                        }
                    }
                }
                .presentationDetents([.large, .fraction(0.5)],
                                     selection: $detent)
                .presentationBackgroundInteraction(.enabled)
            }
        }
    }
}


#Preview {
    IngredientsSelector.preview
}

