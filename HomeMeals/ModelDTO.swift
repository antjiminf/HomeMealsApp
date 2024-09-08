import Foundation

struct IngredientDTO: Codable {
    let id: UUID
    let name: String
    let category: FoodCategory
}

struct RecipeDTO: Codable {
    let id: UUID
    let name: String
    let description: String
    let time: Int
    let guide: [String]
    let allergens: [Allergen]
    let owner: UUID
    let ingredients: RecipeIngredientsDTO
}

struct RecipeListDTO: Codable {
    let id: UUID
    let name: String
    let description: String
    let time: Int
    let allergens: [Allergen]
    let owner: UUID
}

struct RecipeIngredientsDTO: Codable {
    let name: String
    let quantity: Double
    let unit: Unit
}
