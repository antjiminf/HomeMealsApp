import Foundation
import ACNetwork

protocol DataInteractor {
    
    //Users
    func getToken() -> String?
    func register(user: CreateUser) async throws
    func loginSIWA(token: Data, request: SIWARequest) async throws
    func login(username: String, password: String) async throws
    func testJWT() async throws
    func getUserProfile() async throws -> UserProfile
    func updateProfile(_ profile: UpdateProfile) async throws
    func updatePassword(_ request: UpdatePassword) async throws
    
    //Ingredients
    func getAllIngredients() async throws -> [Ingredient]
    func getIngredients(page: Int, perPage: Int) async throws -> Page<Ingredient>
    func searchIngredients(page: Int, perPage: Int) async throws -> Page<Ingredient>
    
    
    //Recipes
    func getRecipes(page: Int, perPage: Int) async throws -> Page<RecipeListItem>
    func filterRecipes(name: String?,
                       minTime: Int?,
                       maxTime: Int?,
                       allergens: [Allergen]?,
                       page: Int,
                       perPage: Int) async throws -> Page<RecipeListItem>
    func getTotalIngredientsInRecipes(recipes: [RecipeQuantity]) async throws -> [Groceries]
    func addRecipe(_ recipe: CreateRecipeDTO) async throws
    func getRecipeIngredients(id: UUID) async throws -> Recipe
    func updateRecipe(id: UUID, updated: CreateRecipeDTO) async throws
    func deleteRecipe(id: UUID) async throws
    func getRecipeFavorites(id: UUID) async throws -> [UserLikeInfo]
    func getUserRecipes() async throws -> [RecipeListItem]
    //Favorites
    func getFavorites() async throws -> [RecipeListItem]
    func addFavorite(id: UUID) async throws
    func removeFavorite(id: UUID) async throws
    
    
    //Inventory
    func getInventory() async throws -> [InventoryItem]
    func getRecipeSuggestions() async throws -> [RecipeListItem]
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
    
    //Auth
    
    func getToken() -> String? {
        guard let token = SecKeyStore.shared.readKey(label: "token") else {
            return nil
        }
        return String(data: token, encoding: .utf8)
    }
    
    func register(user: CreateUser) async throws {
        var request: URLRequest = .post(url: .register, post: user)
        request.setValue(SecManager.shared.apiKey,
                         forHTTPHeaderField: "App-APIKey")
        try await post(request: request, status: 201)
    }
    
    func loginSIWA(token: Data, request: SIWARequest) async throws {
        let accessToken = try await getJSON(request: .post(url: .loginSIWA, post: request,
                                                           token: String(data: token, encoding: .utf8)),
                          type: TokenDTO.self)
        SecKeyStore.shared.storeKey(key: Data(accessToken.token.utf8), label: "token")
        NotificationCenter.default.post(name: .login, object: nil)
    }
    
    func login(username: String, password: String) async throws {
        let token = "\(username):\(password)".data(using: .utf8)?.base64EncodedString()
        let accessToken =  try await getJSON(request: .get(url: .login, token: token, authType: .basic),
                                             type: TokenDTO.self)
        SecKeyStore.shared.storeKey(key: Data(accessToken.token.utf8), label: "token")
        NotificationCenter.default.post(name: .login, object: nil)
    }
    
    func testJWT() async throws {
        try await post(request: .get(url: .testJWT, token: getToken()), status: 200)
    }
    
    func getUserProfile() async throws -> UserProfile {
        try await getJSON(request: .get(url: .profile, token: getToken()), type: UserProfile.self)
    }
    
    func getUserRecipes() async throws -> [RecipeListItem] {
        try await getJSON(request: .get(url: .userRecipes, token: getToken()),
                          type: [RecipeListItem].self)
    }
    
    func updateProfile(_ profile: UpdateProfile) async throws {
        try await post(request: .post(url: .users, post: profile, method: .put, token: getToken()),
                       status: 204)
    }
    
    func updatePassword(_ request: UpdatePassword) async throws {
        try await post(request: .post(url: .userUpdatePassword, post: request, method: .put, token: getToken()),
                       status: 204)
    }
    
    
    // Inventory
    
    func getInventory() async throws -> [InventoryItem] {
        try await getJSON(request: .get(url: .inventory, token: getToken()),
                          type: [InventoryItem].self)
    }
    
    func getRecipeSuggestions() async throws -> [RecipeListItem] {
        try await getJSON(request: .get(url: .inventoryRecipeSuggestions, token: getToken()),
                          type: [RecipeListItem].self)
    }
    
    func addInventoryItem(_ item: ModifyInventoryItemDTO) async throws {
        try await post(request: .post(url: .inventory, post: item, token: getToken()))
    }
    
    func shoppingList(_ ingredients: [ModifyInventoryItemDTO]) async throws -> [Groceries] {
        try await postJSON(request: .post(url: .inventoryGroceriesList, post: ingredients, token: getToken()),
                           type: [Groceries].self,
                           status: 200)
    }
    
    func updateInventory(_ ingredients: [ModifyInventoryItemDTO]) async throws {
        try await post(request: .post(url: .inventory, post: ingredients, method: .put, token: getToken()),
                       status: 204)
    }
    
    func updateInventoryItem(id: UUID, item: ModifyInventoryItemDTO) async throws {
        try await post(request: .post(url: .inventoryItem(id: id), post: item, method: .put, token: getToken()),
                       status: 204)
    }
    
    func addGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws {
        try await post(request: .post(url: .inventoryAddGroceries, post: groceries, method: .put, token: getToken()),
                       status: 204)
    }
    
    func consumeGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws {
        try await post(request: .post(url: .inventoryConsumeGroceries, post: groceries, method: .put, token: getToken()),
                       status: 204)
    }
    
    func deleteInventoryItem(_ id: UUID) async throws {
        try await post(request: .delete(url: .inventoryItem(id: id), token: getToken()),
                       status: 204)
    }
    
    
    
    //Ingredients
    
    func getAllIngredients() async throws -> [Ingredient] {
        try await getJSON(request: .get(url: .ingredientsAll),
                          type: [Ingredient].self)
    }
    
    func getIngredients(page: Int = 1, perPage: Int = 10) async throws -> Page<Ingredient> {
        try await getJSON(
            request: .get(url: .ingredients.appending(queryItems: [
                URLQueryItem(name: "page", value: page.description),
                URLQueryItem(name: "per", value: perPage.description)])),
            type: Page<Ingredient>.self)
    }
    
    //TODO: Falta busqueda
    func searchIngredients(page: Int = 1, perPage: Int = 10) async throws -> Page<Ingredient> {
        try await getJSON(
            request: .get(url: .ingredientsSearch.appending(queryItems: [
                URLQueryItem(name: "page", value: page.description),
                URLQueryItem(name: "per", value: perPage.description)])),
            type: Page<Ingredient>.self)
    }
    
    
    
    //Recipes
    
    func getRecipes(page: Int = 1, perPage: Int = 20) async throws -> Page<RecipeListItem> {
        try await getJSON(
            request: .get(url: .recipes.appending(queryItems: [
                URLQueryItem(name: "page", value: page.description),
                URLQueryItem(name: "per", value: perPage.description)]),
                          token: getToken()),
            type: Page<RecipeListItem>.self)
    }
    
    func filterRecipes(name: String? = nil, minTime: Int? = nil, maxTime: Int? = nil, allergens: [Allergen]? = nil, page: Int = 1, perPage: Int = 20) async throws -> Page<RecipeListItem> {
        
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(contentsOf: [
            URLQueryItem(name: "page", value: page.description),
            URLQueryItem(name: "per", value: perPage.description)
        ])
        
        if let name {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        
        if let minTime {
            queryItems.append(URLQueryItem(name: "minTime", value: minTime.description))
        }
        if let maxTime {
            queryItems.append(URLQueryItem(name: "maxTime", value: maxTime.description))
        }
        if let allergens, !allergens.isEmpty {
            let allergensString = allergens.map { $0.rawValue }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "allergens", value: allergensString))
        }
        
        return try await getJSON(request: .get(url: .recipesSearch.appending(queryItems: queryItems), token: getToken()),
                                 type: Page<RecipeListItem>.self)
    }
    
    func getTotalIngredientsInRecipes(recipes: [RecipeQuantity]) async throws -> [Groceries] {
        try await postJSON(request: .post(url: .recipesTotalIngredients, post: recipes),
                           type: [Groceries].self,
                           status: 200)
    }

    
    func addRecipe(_ recipe: CreateRecipeDTO) async throws {
        try await post(request: .post(url: .recipes, post: recipe, token: getToken()),
                       status: 201)
    }
    
    func getRecipeIngredients(id: UUID) async throws -> Recipe {
        try await getJSON(request: .get(url: .recipesIdIngredients(id: id), token: getToken()),
                          type: Recipe.self)
    }
    
    func updateRecipe(id: UUID, updated: CreateRecipeDTO) async throws {
        try await post(request: .post(url: .recipesId(id: id), post: updated, method: .put, token: getToken()),
                       status: 204)
    }
    
    func deleteRecipe(id: UUID) async throws {
        try await post(request: .delete(url: .recipesId(id: id), token: getToken()),
                       status: 204)
    }
    
    func getRecipeFavorites(id: UUID) async throws -> [UserLikeInfo] {
        try await getJSON(request: .get(url: .recipesIdFavorites(id: id)),
                          type: [UserLikeInfo].self)
    }
    
    //Favorites Interactions
    
    func getFavorites() async throws -> [RecipeListItem] {
        try await getJSON(request: .get(url: .favorites, token: getToken()),
                          type: [RecipeListItem].self)
    }
    
    func addFavorite(id: UUID) async throws {
        try await post(request: .post(url: .favorites, post: id, token: getToken()),
                       status: 201)
    }
    
    func removeFavorite(id: UUID) async throws {
        try await post(request: .delete(url: .favoritesId(id: id), token: getToken()),
                       status: 204)
    }
}
