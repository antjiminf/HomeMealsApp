import Foundation

let api = URL(string: "http://localhost:8080/api")!

extension URL {
    
    //Users-Auth
    static let users = api.appending(path: "users")
    static let login = users.appending(path: "login")
    static let loginSIWA = users.appending(path: "loginSIWA")
    static let register = users.appending(path: "register")
    static let testJWT = users.appending(path: "testJWT")
    static let profile = users.appending(path: "profile")
    static let userRecipes = users.appending(path: "recipes")
    static let userUpdatePassword = users.appending(path: "password")
    
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
    static let recipesTotalIngredients = recipes.appending(path: "total-ingredients")
    static func recipesId(id: UUID) -> URL {
        recipes.appending(path: id.uuidString)
    }
    static func recipesIdIngredients(id: UUID) -> URL {
        recipes.appending(path: "\(id.uuidString)/ingredients")
    }
    static func recipesIdFavorites(id: UUID) -> URL {
        recipes.appending(path: "\(id.uuidString)/favorites")
    }
    //Favorites
    static let favorites = recipes.appending(path: "favorites")
    static func favoritesId(id: UUID) -> URL {
        favorites.appending(path: id.uuidString)
    }
    
}
