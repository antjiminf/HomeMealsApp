import Foundation


struct IngredientDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let unit: Unit
    let category: FoodCategory
}

struct SelectionIngredient: Identifiable, Hashable {
    let id: UUID
    let name: String
    let unit: Unit
    var quantity: Double
//    let category: FoodCategory
    
    func toCreateRecipeIngredient() -> CreateRecipeIngredient {
        CreateRecipeIngredient(ingredient: id, quantity: quantity, unit: unit)
    }
}

struct RecipeIngredient: Identifiable, Codable, Hashable {
    let ingredientId: UUID
    let name: String
    let quantity: Double
    let unit: Unit
    
    var id: UUID { ingredientId }
    
    func toSelectionIngredient() -> SelectionIngredient {
        return SelectionIngredient(id: ingredientId,
                                   name: name,
                                   unit: unit,
                                   quantity: quantity
        )
    }
}

struct CreateRecipeIngredient: Codable, Hashable {
    let ingredient: UUID
    let quantity: Double
    let unit: Unit
}
