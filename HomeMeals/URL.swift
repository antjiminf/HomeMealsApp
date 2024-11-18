import Foundation

let api = URL(string: "http://localhost:8080/api")!

extension URL {
    
    // Inventory
    static let inventory = api.appending(path: "users/inventory")
    static let inventoryRecipeSuggestions = inventory.appending(path: "recipe-suggestions")
    static let inventoryGroceriesList = inventory.appending(path: "groceries-list")
    static let inventoryAddGroceries = inventory.appending(path: "groceries")
    static let inventoryConsumeGroceries = inventory.appending(path: "consume")
    static func inventoryItem(id: UUID) -> URL {
        inventory.appending(path: id.uuidString)
    }
    
    // Ingredients
    static let ingredients = api.appending(path: "ingredients")
    static let ingredientsAll = ingredients.appending(path: "all")
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
