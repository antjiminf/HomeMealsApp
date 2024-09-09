import Foundation

let api = URL(string: "http://localhost:8080/api")!

extension URL {
    
    // Ingredients
    static let ingredients = api.appending(path: "ingredients")
    static let ingredientsSearch = ingredients.appending(path: "search")
    static let ingredientsCategory = ingredients.appending(path: "category")
    static func ingredientsIdRecipes(id: UUID) -> URL {
        ingredients.appending(path: "\(id.uuidString)/recipes")
    }
    static func ingredientsId(id: UUID) -> URL {
        ingredients.appending(path: id.uuidString)
    }
    
    // Recipes
    static let recipes = api.appending(path: "recipes")
    static let recipesSearch = recipes.appending(path: "search")
    static func recipesId(id: UUID) -> URL {
        recipes.appending(path: id.uuidString)
    }
    static func recipesIdIngredients(id: UUID) -> URL {
        recipes.appending(path: "\(id.uuidString)/ingredients")
    }
    
}
