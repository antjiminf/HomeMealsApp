import SwiftUI
import ACNetwork

//extension RecipeDTO {
//    var toPresentationRecipe: RecipeDTO {
//        RecipeDTO(id: <#T##UUID#>, name: <#T##String#>, description: <#T##String#>, time: <#T##Int#>, guide: <#T##[String]#>, allergens: <#T##[Allergen]#>, owner: <#T##UUID#>, ingredients: <#T##RecipeIngredientsDTO#>)
//    }
//}

extension [SelectionIngredient] {
    static var test = [
        SelectionIngredient(id: UUID(uuidString: "623E4567-E89B-12D3-A456-426614174005")! , name: "Sugar", unit: .weight, quantity: 2/*, category: .bakeryPastry*/),
        SelectionIngredient(id: UUID(uuidString: "723E4567-E89B-12D3-A456-426614174006")!, name: "Egg", unit: .units, quantity: 3/*, category: .meat*/)
    ]
}

extension InventoryItemDTO {
    static var test = InventoryItemDTO(id: UUID(uuidString: "B07B2DF9-2A7C-4280-A14B-6E503AA2581D")!,
                                       ingredientId: UUID(uuidString: "623E4567-E89B-12D3-A456-426614174005")!,
                                       name: "Sugar",
                                       unit: .weight,
                                       quantity: 20)
}

struct InteractorTest: DataInteractor {
    func getInventory() async throws -> [InventoryItemDTO] {
        [
            InventoryItemDTO(id: UUID(uuidString: "B07B2DF9-2A7C-4280-A14B-6E503AA2581D")!,
                             ingredientId: UUID(uuidString: "623E4567-E89B-12D3-A456-426614174005")!,
                             name: "Sugar",
                             unit: .weight,
                             quantity: 20),
            InventoryItemDTO(id: UUID(uuidString: "74092453-BE2A-4FF6-AC3A-30274A65B906")!,
                             ingredientId: UUID(uuidString: "423E4567-E89B-12D3-A456-426614174003")!,
                             name: "Milk",
                             unit: .volume,
                             quantity: 2),
            InventoryItemDTO(id: UUID(uuidString: "5087909C-0AB6-4AAD-BA2B-03A2006D4724")!,
                             ingredientId: UUID(uuidString: "723E4567-E89B-12D3-A456-426614174006")!,
                             name: "Egg",
                             unit: .units,
                             quantity: 4)
        ]
    }
    
    func getRecipeSuggestions() async throws -> [RecipeListDTO] {
        []
    }
    
    func addInventoryItem(_ item: ModifyInventoryItemDTO) async throws {
        
    }
    
    func shoppingList(_ ingredients: [ModifyInventoryItemDTO]) async throws -> [Groceries] {
        []
    }
    
    func updateInventory(_ ingredients: [ModifyInventoryItemDTO]) async throws {
        
    }
    
    func updateInventoryItem(id: UUID, item: ModifyInventoryItemDTO) async throws {
        
    }
    
    func addGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws {
        
    }
    
    func consumeGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws {
        
    }
    
    func deleteInventoryItem(_ id: UUID) async throws {
        
    }
    
    
    func addRecipe(_ recipe: CreateRecipeDTO) async throws {
//        try await post(request: .post(url: .recipes, post: recipe), status: 201)
    }
    
    func getAllIngredients() async throws -> [IngredientDTO] {
        guard let url = Bundle.main.url(forResource: "ingredients", withExtension: "json") else {
            return []
        }
        return try getJSON(url: url, type: [IngredientDTO].self)
    }
    
    func getIngredients(page: Int, perPage: Int) async throws -> Page<IngredientDTO> {
        guard let url = Bundle.main.url(forResource: "ingredients", withExtension: "json") else {
            return Page(items: [], page: page, perPage: perPage, total: 0)
        }
        
        let ingredients = try getJSON(url: url, type: [IngredientDTO].self)
        let total = ingredients.count
        
        let first = (page - 1) * perPage
        let last = min(first + perPage, total)
        
        guard first < total else {
            return Page(items: [], page: page, perPage: perPage, total: total)
        }
        
        let paginatedIngredients = Array(ingredients[first..<last])
        return Page(items: paginatedIngredients, page: page, perPage: perPage, total: total)
    }
    
    func searchIngredients(page: Int, perPage: Int) async throws -> Page<IngredientDTO> {
        //        guard let url = Bundle.main.url(forResource: "ingredients", withExtension: "json") else {
        //            return Page(items: [], page: page, perPage: perPage, total: 0)
        //        }
        return Page(items: [], page: 1, perPage: 10, total: 0)
    }
    
    func getRecipes(page: Int, perPage: Int) async throws -> Page<RecipeListDTO> {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            return Page(items: [], page: page, perPage: perPage, total: 0)
        }
        
        let recipes = try getJSON(url: url, type: [RecipeListDTO].self)
        let total = recipes.count
        
        let first = (page - 1) * perPage
        let last = min(first + perPage, total)
        
        guard first < total else {
            return Page(items: [], page: page, perPage: perPage, total: total)
        }
        
        let paginatedRecipes = Array(recipes[first..<last])
        return Page(items: paginatedRecipes, page: page, perPage: perPage, total: total)
    }
    
    func getJSON<JSON>(url: URL, type: JSON.Type) throws -> JSON where JSON: Codable {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
}


extension RecipeView {
    static var preview: some View {
        RecipeView()
            .environment(RecipesVM(interactor: InteractorTest()))
            .environment(IngredientsVM(interactor: InteractorTest()))
    }
}

extension AddRecipeView {
    static var preview: some View {
        NavigationStack {
            AddRecipeView(addRecipeVm: AddRecipeVM())
                .environment(RecipesVM(interactor: InteractorTest()))
                .environment(IngredientsVM(interactor: InteractorTest()))
        }
    }
}

extension IngredientsSelector {
    static var preview: some View {
        NavigationStack {
            IngredientsSelector(selectorVM: IngredientSelectorVM(), 
                                selectedIngredients: .constant(.test),
                                title: "Select ingredients")
                .environment(IngredientsVM(interactor: InteractorTest()))
        }
    }
}

extension InventoryView {
    static var preview: some View {
        InventoryView()
            .environment(InventoryVM(interactor: InteractorTest()))
            .environment(IngredientsVM(interactor: InteractorTest()))
    }
}

extension IngredientQuantity {
    static var preview: some View {
        IngredientQuantity(ingredientName: "Banana", quantity: .constant(2), unit: .units)
    }
}

extension EditQuantityView {
    static var preview: some View {
        NavigationStack {
            EditQuantityView(inventoryItemVm: InventoryItemVm(inventoryItem: .test))
                .environment(InventoryVM(interactor: InteractorTest()))
        }
    }
}

