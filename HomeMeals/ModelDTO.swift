import Foundation

struct Page<T: Codable>: Codable {
    let items: [T]
    let page: Int
    let perPage: Int
    let total: Int
}

struct IngredientDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let unit: Unit
    let category: FoodCategory
}

struct RecipeDTO: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let time: Int
    let guide: [String]
    let allergens: [Allergen]
    let owner: UUID
    let ingredients: RecipeIngredientDTO
}

struct RecipeListDTO: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let time: Int
    let allergens: [Allergen]
    let owner: UUID
}

struct SelectionIngredient: Identifiable, Hashable {
    let id: UUID
    let name: String
    let unit: Unit
    var quantity: Double
//    let category: FoodCategory
    
    func toRecipeIngredient() -> RecipeIngredientDTO {
        RecipeIngredientDTO(ingredient: id, quantity: quantity, unit: unit)
    }
}

struct RecipeIngredientDTO: Codable, Hashable {
    
    let ingredient: UUID
    let quantity: Double
    let unit: Unit
}

struct CreateRecipeDTO: Codable {
    let name: String
    let description: String
    let time: Int
    let isPublic: Bool
    let ingredients: [RecipeIngredientDTO]
    let guide: [String]
    let allergens: [Allergen]
}
