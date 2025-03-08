import SwiftUI

@Observable
final class MealSelectionVM {
    var selectedMeals: [Meal] = []
    
    func addMeal(recipe: RecipeListItem, type: MealType) {
        if let index = selectedMeals.firstIndex(where: { $0.type == type }) {
            selectedMeals[index].recipeId = recipe.id
            selectedMeals[index].recipeName = recipe.name
        } else {
            selectedMeals.append(Meal(type: type, recipeId: recipe.id, recipeName: recipe.name))
        }
    }
    
    func removeMeal(type: MealType) {
        selectedMeals.removeAll { $0.type == type }
    }
}
