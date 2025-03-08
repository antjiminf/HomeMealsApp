import SwiftUI
import SwiftData

struct RecipeSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(RecipesVM.self) var recipesVm
    let mealPlanner: MealPlannerVM

    @State private var selectedRecipe: RecipeListItem?

    var body: some View {
        NavigationStack {
            List(recipesVm.recipes) { recipe in
                HStack {
                    Text(recipe.name)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if selectedRecipe == recipe {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedRecipe = recipe
                }
            }
            .navigationTitle("Select Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        if let selectedRecipe {
                            mealPlanner.addMeal(
                                date: mealPlanner.selectedDate,
                                mealType: mealPlanner.selectedMealType,
                                recipe: selectedRecipe,
                                in: modelContext
                            )
                            dismiss()
                        }
                    }
                    .disabled(selectedRecipe == nil)
                }
            }
        }
    }
}


#Preview {
    RecipeSelectionView(mealPlanner: .init())
        .environment(RecipesVM(interactor: InteractorTest()))
}
