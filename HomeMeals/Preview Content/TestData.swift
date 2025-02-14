import SwiftUI
import ACNetwork



extension [SelectionIngredient] {
    static var test = [
        SelectionIngredient(id: UUID(uuidString: "623E4567-E89B-12D3-A456-426614174005")! , name: "Sugar", unit: .weight, quantity: 2/*, category: .bakeryPastry*/),
        SelectionIngredient(id: UUID(uuidString: "723E4567-E89B-12D3-A456-426614174006")!, name: "Egg", unit: .units, quantity: 3/*, category: .meat*/)
    ]
}

extension InventoryItem {
    static var test = InventoryItem(id: UUID(uuidString: "B07B2DF9-2A7C-4280-A14B-6E503AA2581D")!,
                                       ingredientId: UUID(uuidString: "623E4567-E89B-12D3-A456-426614174005")!,
                                       name: "Sugar",
                                       unit: .weight,
                                       quantity: 20)
}

extension Recipe {
    static var test = Recipe(id: UUID(),
                                name: "Grilled Chicken Salad",
                                description: "The best chicken recipe you would ever see",
                                time: 20,
                                guide: ["First step", "Second step", "Third step", "Fourth step"],
                                allergens: [.egg],
                                owner: UUID(),
                                ingredients: [
                                    RecipeIngredient(ingredientId: UUID(),
                                                     name: "Egg",
                                                     quantity: 2,
                                                     unit: .units),
                                    RecipeIngredient(ingredientId: UUID(),
                                                     name: "Water",
                                                     quantity: 3.2,
                                                     unit: .volume),
                                    RecipeIngredient(ingredientId: UUID(),
                                                     name: "Olive Oil",
                                                     quantity: 0.2,
                                                     unit: .volume)],
                                favorite: true,
                                favTotal: 300)
}

extension RecipeListItem {
    static var test = RecipeListItem(id: UUID(),
                                    name: "Papas",
                                    description: "Las mejores papas de la historia",
                                    time: 20,
                                    allergens: [.dairy],
                                    owner: UUID(),
                                    favorite: true,
                                    favTotal: 204000)
}

extension UserLikeInfo {
    static var test = UserLikeInfo(id: UUID(), name: "Cristiano Ronaldo")
}

struct InteractorTest: DataInteractor {
    
    
    func filterRecipes(name: String?, minTime: Int?, maxTime: Int?, allergens: [Allergen]?, page: Int, perPage: Int) async throws -> Page<RecipeListItem> {
        return Page(items: [], page: 1, perPage: 10, total: 10)
    }
    
    func getTotalIngredientsInRecipes(recipes: [RecipeQuantity]) async throws -> [Groceries] {
        [
            Groceries(ingredientId: UUID(), name: "Bread", requiredQuantity: 100, unit: .units),
            Groceries(ingredientId: UUID(), name: "Egg", requiredQuantity: 50, unit: .units),
            Groceries(ingredientId: UUID(), name: "Oil", requiredQuantity: 0.5, unit: .volume),
            Groceries(ingredientId: UUID(), name: "Chicken", requiredQuantity: 200, unit: .weight)
        ]
    }
    
    
    func getRecipeIngredients(id: UUID) async throws -> Recipe {
        Recipe.test
    }
    
    func updateRecipe(id: UUID, updated: CreateRecipeDTO) async throws {}
    
    func deleteRecipe(id: UUID) async throws {}
    
    func getRecipeSuggestions() async throws -> [RecipeListItem] {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            return [.test]
        }
        let recipes = try getJSON(url: url, type: [RecipeListItem].self)
        return recipes
        
    }
    
    func getRecipeFavorites(id: UUID) async throws -> [UserLikeInfo] {
        [UserLikeInfo(id: UUID(), name: "Cristiano Ronaldo"),
         UserLikeInfo(id: UUID(), name: "Lionel Messi"),
         UserLikeInfo(id: UUID(), name: "Neymar Jr."),
         UserLikeInfo(id: UUID(), name: "Kylian Mbappé")]
    }
    
    func getFavorites() async throws -> [RecipeListItem] {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            return []
        }
        let recipes = try getJSON(url: url, type: [RecipeListItem].self)
        return recipes
    }
    
    func addFavorite(id: UUID) async throws {
    }
    
    func removeFavorite(id: UUID) async throws {
    }
    
    //INVENTORY
    
    func getInventory() async throws -> [InventoryItem] {
        [
            InventoryItem(id: UUID(uuidString: "B07B2DF9-2A7C-4280-A14B-6E503AA2581D")!,
                             ingredientId: UUID(uuidString: "623E4567-E89B-12D3-A456-426614174005")!,
                             name: "Sugar",
                             unit: .weight,
                             quantity: 20),
            InventoryItem(id: UUID(uuidString: "74092453-BE2A-4FF6-AC3A-30274A65B906")!,
                             ingredientId: UUID(uuidString: "423E4567-E89B-12D3-A456-426614174003")!,
                             name: "Milk",
                             unit: .volume,
                             quantity: 2),
            InventoryItem(id: UUID(uuidString: "5087909C-0AB6-4AAD-BA2B-03A2006D4724")!,
                             ingredientId: UUID(uuidString: "723E4567-E89B-12D3-A456-426614174006")!,
                             name: "Egg",
                             unit: .units,
                             quantity: 4)
        ]
    }
    
    func addInventoryItem(_ item: ModifyInventoryItemDTO) async throws {}
    
    func shoppingList(_ ingredients: [ModifyInventoryItemDTO]) async throws -> [Groceries] {
        []
    }
    
    func updateInventory(_ ingredients: [ModifyInventoryItemDTO]) async throws {}
    
    func updateInventoryItem(id: UUID, item: ModifyInventoryItemDTO) async throws {}
    
    func addGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws {}
    
    func consumeGroceries(_ groceries: [ModifyInventoryItemDTO]) async throws {}
    
    func deleteInventoryItem(_ id: UUID) async throws {}
    
    
    func addRecipe(_ recipe: CreateRecipeDTO) async throws {
        //        try await post(request: .post(url: .recipes, post: recipe), status: 201)
    }
    
    func getAllIngredients() async throws -> [Ingredient] {
        guard let url = Bundle.main.url(forResource: "ingredients", withExtension: "json") else {
            return []
        }
        return try getJSON(url: url, type: [Ingredient].self)
    }
    
    func getIngredients(page: Int, perPage: Int) async throws -> Page<Ingredient> {
        guard let url = Bundle.main.url(forResource: "ingredients", withExtension: "json") else {
            return Page(items: [], page: page, perPage: perPage, total: 0)
        }
        
        let ingredients = try getJSON(url: url, type: [Ingredient].self)
        let total = ingredients.count
        
        let first = (page - 1) * perPage
        let last = min(first + perPage, total)
        
        guard first < total else {
            return Page(items: [], page: page, perPage: perPage, total: total)
        }
        
        let paginatedIngredients = Array(ingredients[first..<last])
        return Page(items: paginatedIngredients, page: page, perPage: perPage, total: total)
    }
    
    func searchIngredients(page: Int, perPage: Int) async throws -> Page<Ingredient> {
        //        guard let url = Bundle.main.url(forResource: "ingredients", withExtension: "json") else {
        //            return Page(items: [], page: page, perPage: perPage, total: 0)
        //        }
        return Page(items: [], page: 1, perPage: 10, total: 0)
    }
    
    func getRecipes(page: Int, perPage: Int) async throws -> Page<RecipeListItem> {
        //TODO: SI TUVIESE SUFICIENTES RECETAS PODRÍA PROBAR EL SCROLL INFINITO EN PREVIEWS
//        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
//            return Page(items: [], page: page, perPage: perPage, total: 0)
//        }
//        
//        let recipes = try getJSON(url: url, type: [RecipeListDTO].self)
//        let total = recipes.count
//        
//        let first = (page - 1) * perPage
//        let last = min(first + perPage, total)
//        
//        guard first < total else {
//            return Page(items: [], page: page, perPage: perPage, total: total)
//        }
//        
//        let paginatedRecipes = Array(recipes[first..<last])
//        return Page(items: paginatedRecipes, page: page, perPage: perPage, total: total)
        Page(items: [.test,
                     .test,
                     .test
                    ],
             page: 1,
             perPage: 10,
             total: 1)
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

extension FavoriteRecipesView {
    static var preview: some View {
        FavoriteRecipesView()
            .environment(RecipesVM(interactor: InteractorTest()))
    }
}

extension RecipeFormView {
    static var preview: some View {
        NavigationStack {
            RecipeFormView(addRecipeVm: AddRecipeVM(), title: "Recipe Form", method: .CREATE)
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
            .environment(RecipesVM(interactor: InteractorTest()))
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
            EditQuantityView(inventoryItemVm: InventoryItemVM(inventoryItem: .test), onUpdate: {})
                .environment(InventoryVM(interactor: InteractorTest()))
        }
    }
}

extension RecipeDetailsView {
    static var preview: some View {
        NavigationStack {
            RecipeDetailsView(/*recipeId: UUID(), */recipeDetailsVm: RecipeDetailsVM(interactor: InteractorTest(), recipeId: UUID()))
                .environment(RecipesVM(interactor: InteractorTest()))
        }
    }
}

extension FilterRecipesView {
    static var preview: some View {
        NavigationStack {
            FilterRecipesView(filterVm: FilterRecipesVM())
                .environment(RecipesVM(interactor: InteractorTest()))
        }
    }
}

extension UsersLikesList {
    static var preview: some View {
        NavigationStack {
            UsersLikesList(recipeDetailsVm: RecipeDetailsVM(interactor: InteractorTest(), recipeId: UUID()))
        }
    }
}

extension SuggestedRecipesList {
    static var preview: some View {
        NavigationStack {
            SuggestedRecipesList()
                .environment(RecipesVM(interactor: InteractorTest()))
        }
    }
}

