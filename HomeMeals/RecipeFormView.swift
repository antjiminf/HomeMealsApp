import SwiftUI

enum MethodType {
    case UPDATE
    case CREATE
}

struct RecipeFormView: View {
    @Environment(\.dismiss) private var dismiss
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
                    MinutesStepper( 
                        label: "Recipe time",
                        value: $addRecipeVm.time,
                        initial: false,
                        hint: "Recipe time of preparation",
                        isError: $addRecipeVm.error,
                        validation: addRecipeVm.validationTime)
                    Toggle(addRecipeVm.isPublic ? "Public recipe" : "Private recipe", isOn: $addRecipeVm.isPublic)
                        .bold()
                }
                
                Section("Details") {
                    IngredientsSelectedList(showIngredientsForm: $showIngredientsForm,
                                            ingredients: $addRecipeVm.ingredients,
                                            isError: $addRecipeVm.error,
//                                            removeIngredient: addRecipeVm.removeIngredient,
                                            validation: addRecipeVm.validateIngredients)
                    
                    GuideField(guide: $addRecipeVm.guide,
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
        }
    }
}

#Preview {
    RecipeFormView.preview
}
