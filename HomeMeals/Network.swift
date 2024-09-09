import Foundation
import ACNetwork

struct Network: NetworkJSONInteractor {
    static let shared = Network()
    
    //Ingredients
    func getIngredients(page: Int = 1, perPage: Int = 10) async throws -> [IngredientDTO] {
        try await getJSON(request: .get(url: .ingredients.appending(path: "?page=\(page)&per=\(perPage)")), type: [IngredientDTO].self)
    }
    // Falta busqueda
    func searchIngredients(page: Int = 1, perPage: Int = 10) async throws -> [IngredientDTO] {
        try await getJSON(request: .get(url: .ingredientsSearch.appending(path: "?page=\(page)&per=\(perPage)")), type: [IngredientDTO].self)
    }
    
    //Recipes
    func getRecipes(page: Int = 1, perPage: Int = 10) async throws -> [RecipeDTO] {
        try await getJSON(request: .get(url: .recipes.appending(path: "?page=\(page)&per=\(perPage)")), type: [RecipeDTO].self)
    }
}
