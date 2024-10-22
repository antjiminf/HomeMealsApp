import Foundation
import ACNetwork

protocol DataInteractor {
    func getAllIngredients() async throws -> [IngredientDTO]
    func getIngredients(page: Int, perPage: Int) async throws -> Page<IngredientDTO>
    func searchIngredients(page: Int, perPage: Int) async throws -> Page<IngredientDTO>
    func getRecipes(page: Int, perPage: Int) async throws -> Page<RecipeListDTO>
    func addRecipe(_ recipe: CreateRecipeDTO) async throws
    
}

struct Network: NetworkJSONInteractor, DataInteractor {
    static let shared = Network()
    
    //Ingredients
    func getAllIngredients() async throws -> [IngredientDTO] {
        try await getJSON(request: .get(url: .ingredientsAll), type: [IngredientDTO].self)
    }
    func getIngredients(page: Int = 1, perPage: Int = 10) async throws -> Page<IngredientDTO> {
        try await getJSON(
            request: .get(url: .ingredients.appending(queryItems: [
                URLQueryItem(name: "page", value: page.description),
                URLQueryItem(name: "per", value: perPage.description)
            ])),
            type: Page<IngredientDTO>.self)
    }
    //TODO: Falta busqueda
    func searchIngredients(page: Int = 1, perPage: Int = 10) async throws -> Page<IngredientDTO> {
        try await getJSON(
            request: .get(url: .ingredientsSearch.appending(queryItems: [
                URLQueryItem(name: "page", value: page.description),
                URLQueryItem(name: "per", value: perPage.description)
            ])),
            type: Page<IngredientDTO>.self)
    }
    
    //Recipes
    func getRecipes(page: Int = 1, perPage: Int = 20) async throws -> Page<RecipeListDTO> {
        try await getJSON(
            request: .get(url: .recipes.appending(queryItems: [
                URLQueryItem(name: "page", value: page.description),
                URLQueryItem(name: "per", value: perPage.description)
            ])),
            type: Page<RecipeListDTO>.self)
    }
    
    func addRecipe(_ recipe: CreateRecipeDTO) async throws {
        try await post(request: .post(url: .recipes, post: recipe), status: 201)
    }
}
