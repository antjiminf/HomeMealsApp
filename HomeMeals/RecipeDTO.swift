import Foundation

struct Page<T: Codable>: Codable {
    let items: [T]
    let page: Int
    let perPage: Int
    let total: Int
}

struct RecipeDTO: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let time: Int
    let guide: [String]
    let allergens: [Allergen]
    let owner: UUID
    let ingredients: [RecipeIngredient]
}

struct RecipeListDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let time: Int
    let allergens: [Allergen]
    let owner: UUID
}

struct CreateRecipeDTO: Codable {
    let name: String
    let description: String
    let time: Int
    let isPublic: Bool
    let ingredients: [CreateRecipeIngredient]
    let guide: [String]
    let allergens: [Allergen]
}
