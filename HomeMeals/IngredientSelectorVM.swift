import Foundation

@Observable
final class IngredientSelectorVM {
    
    var selectedIngredients: [SelectionIngredient] = []
    
    var sortedIngredients: [SelectionIngredient] {
        selectedIngredients.sorted(by: {$0.name < $1.name})
    }
    
    var showSelectedIngredients = false
    
    func loadInitialSelectedIngredients(_ ingredients: [SelectionIngredient]) {
        self.selectedIngredients = ingredients
    }
    
    func updateIngredientSelection(ingredient: Ingredient, quantity: Int) {
        if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
            if quantity > 0 {
                selectedIngredients[index].quantity = quantity
            } else {
                selectedIngredients.remove(at: index)
            }
        } else if quantity > 0 {
            let newSelection = SelectionIngredient(id: ingredient.id, name: ingredient.name, unit: ingredient.unit, quantity: quantity)
            selectedIngredients.append(newSelection)
        }
    }
    
    func quantityForIngredient(_ ingredient: Ingredient) -> Int {
        return selectedIngredients.first(where: { $0.id == ingredient.id })?.quantity ?? 0
    }
    
    func saveIngredients() -> [SelectionIngredient] {
        return sortedIngredients
    }
}
