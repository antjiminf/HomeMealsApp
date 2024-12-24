import SwiftUI

@Observable
final class RecipesVM {
    private let interactor: DataInteractor
    
    var recipes: [RecipeListDTO] = []
    var suggestedRecipes: [RecipeListDTO] = []
    var searchedRecipes: [RecipeListDTO] {
        recipes.filter { r in
            search.isEmpty || r.name.localizedCaseInsensitiveContains(search)
        }
    }
    
    var isLoadingPage: Bool = false
    private var totalPages: Int = 1
    private var page: Int = 1
    private var perPage: Int = 10
    
    var search: String = ""
    var hasError: Bool = false
    var errorMessage: String?
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
        Task {
            await initRecipes()
        }
    }
    
    func initRecipes() async {
        
        isLoadingPage = true
        defer { isLoadingPage = false }
        
        async let recipesQuery = interactor.getRecipes(page: page, perPage: perPage)
        async let suggestionsQuery = interactor.getRecipeSuggestions()
        
        do {
            let (suggestionsResult, recipesResult) = try await (suggestionsQuery, recipesQuery)
            recipes = recipesResult.items
            suggestedRecipes = suggestionsResult
            totalPages = recipesResult.total
        } catch {
            hasError = true
            errorMessage = "Failed to fetch recipes"
        }
    }
    
    func getNextRecipes() async {
        guard page < totalPages && !isLoadingPage else { return }
        
        isLoadingPage = true
        defer { isLoadingPage = false }
        
        page += 1
        
        do {
            let result = try await interactor.getRecipes(page: page, perPage: perPage)
            recipes.append(contentsOf: result.items)
        } catch {
            hasError = true
            errorMessage = "Failed to fetch recipes"
        }
    }
    
    //    func filterRecipes() async {
    //        do {
    //            let result = try await interactor.filterRecipes(minTime: 0, maxTime: 0, allergens: [])
    //            
    //        } catch {
    //            hasError = true
    //            errorMessage = "Failed to fetch recipes"
    //        }
    //    }
    
    func addRecipe(_ new: CreateRecipeDTO) async {
        do {
            try await interactor.addRecipe(new)
            resetPagination()
            await initRecipes()
        } catch {
            print(error.localizedDescription)
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func updateRecipe(id: UUID, updated: CreateRecipeDTO) async {
        do {
            try await interactor.updateRecipe(id: id, updated: updated)
            resetPagination()
            await initRecipes()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func getRecipeDetails(id: UUID) async -> RecipeDTO? {
        do {
            return try await interactor.getRecipeIngredients(id: id)
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    func deleteRecipe(id: UUID) async {
        do {
            try await interactor.deleteRecipe(id: id)
            resetPagination()
            await initRecipes()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func getSuggestedRecipes() async {
        do {
            suggestedRecipes = try await interactor.getRecipeSuggestions()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func resetPagination() {
        page = 1
        totalPages = 1
        recipes = []
    }
    
    func hasReachedEnd(recipe: RecipeListDTO) -> Bool {
        recipes.last?.id == recipe.id
    }
}
