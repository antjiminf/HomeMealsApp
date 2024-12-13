import Foundation
import ACNetwork

protocol DataInteractor {
    
    //Ingredients
    func getAllIngredients() async throws -> [IngredientDTO]
    func getIngredients(page: Int, perPage: Int) async throws -> Page<IngredientDTO>
    func searchIngredients(page: Int, perPage: Int) async throws -> Page<IngredientDTO>
    
    //Recipes
    func getRecipes(page: Int, perPage: Int) async throws -> Page<RecipeListDTO>
    func addRecipe(_ recipe: CreateRecipeDTO) async throws
    func getRecipeIngredients(id: UUID) async throws -> RecipeDTO
    func updateRecipe(id: UUID, updated: CreateRecipeDTO) async throws
    func deleteRecipe(id: UUID) async throws
    
    //Inventory
    func getInventory() async throws -> [InventoryItemDTO]
    func getRecipeSuggestions() async throws -> [RecipeListDTO]
    func addInventoryItem(_ item: ModifyInventoryItemDTO) async throws
    func shoppingList(_ ingredients: [ModifyInventoryItemDTO]) async throws -> [Groceries]
    func updateInventory(_ ingredients: [ModifyInventoryItemDTO]) async throws
    func updateInventoryItem(id: UUID, item: ModifyInventoryItemDTO) async throws
    func addGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws
    func consumeGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws
    func deleteInventoryItem(_ id: UUID) async throws
    
}

extension NetworkJSONInteractor {
    
    func postJSON<JSON>(request: URLRequest, type: JSON.Type, status: Int = 200) async throws -> JSON where JSON: Codable {
        let (data, response) = try await session.getData(for: request)
        if response.statusCode == status {
            do {
                return try JSONDecoder.isoDecoder.decode(type, from: data)
            } catch {
                throw NetworkError.json(error)
            }
        } else {
            throw NetworkError.status(response.statusCode)
        }
    }
}

extension URLRequest {
    static func delete(url: URL,
                token: String? = nil,
                authType: AuthType = .token) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = 60
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        switch authType {
            case .basic:
                if let token {
                    request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
                }
            case .token:
                if let token {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
        }
        return request
    }
}

struct Network: NetworkJSONInteractor, DataInteractor {
    
    static let shared = Network()
    
    
    // Inventory
    
    func getInventory() async throws -> [InventoryItemDTO] {
        try await getJSON(request: .get(url: .inventory), type: [InventoryItemDTO].self)
    }
    
    func getRecipeSuggestions() async throws -> [RecipeListDTO] {
        try await getJSON(request: .get(url: .inventoryRecipeSuggestions), type: [RecipeListDTO].self)
    }
    
    func addInventoryItem(_ item: ModifyInventoryItemDTO) async throws {
        try await post(request: .post(url: .inventory, post: item))
    }
    
    func shoppingList(_ ingredients: [ModifyInventoryItemDTO]) async throws -> [Groceries] {
        try await postJSON(request: .post(url: .inventoryGroceriesList, post: ingredients),
                           type: [Groceries].self,
                           status: 200)
    }
    
    func updateInventory(_ ingredients: [ModifyInventoryItemDTO]) async throws {
        try await post(request: .post(url: .inventory, post: ingredients, method: .put),
                       status: 204)
    }
    
    func updateInventoryItem(id: UUID, item: ModifyInventoryItemDTO) async throws {
        try await post(request: .post(url: .inventoryItem(id: id), post: item, method: .put), 
                       status: 204)
    }
    
    func addGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws {
        try await post(request: .post(url: .inventoryAddGroceries, post: groceries, method: .put), 
                       status: 204)
    }
    
    func consumeGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws {
        try await post(request: .post(url: .inventoryConsumeGroceries, post: groceries, method: .put),
                       status: 204)
    }
    
    func deleteInventoryItem(_ id: UUID) async throws {
        try await post(request: .delete(url: .inventoryItem(id: id)),
                       status: 204)
    }
    
    
    
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
        try await post(request: .post(url: .recipes, post: recipe), 
                       status: 201)
    }
    
    func getRecipeIngredients(id: UUID) async throws -> RecipeDTO {
        try await getJSON(request: .get(url: .recipesIdIngredients(id: id)), 
                          type: RecipeDTO.self)
    }
    
    func updateRecipe(id: UUID, updated: CreateRecipeDTO) async throws {
        try await post(request: .post(url: .recipesId(id: id), post: updated, method: .put), status: 204)
    }
    
    func deleteRecipe(id: UUID) async throws {
        try await post(request: .delete(url: .recipesId(id: id)),
                       status: 204)
    }
}
