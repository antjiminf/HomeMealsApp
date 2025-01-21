import SwiftUI

@Observable
final class RecipesVM {
    private let interactor: DataInteractor
    
    var recipes: [RecipeListDTO] = []
    var suggestedRecipes: [RecipeListDTO] = []
//        var searchedRecipes: [RecipeListDTO] {
//            recipes.filter { r in
//                search.isEmpty || r.name.localizedCaseInsensitiveContains(search)
//            }
//        }
//        var search: String = ""
    
    private let perPage = 30
    private var page = 1
    private var totalPages: Int?
    
    var isFiltered: Bool = false
    private var filters: (String?, Int?, Int?, [Allergen]?)
    var filteredRecipes: [RecipeListDTO] = []
    private var filteredPage: Int = 1
    private var filteredTotalPages: Int?
    
    var hasError: Bool = false
    var errorMessage: String?
    var viewState: ViewState?
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
        Task {
            await initRecipes()
        }
    }
    
    func initRecipes() async {
        reset()
        viewState = .loading
        defer { viewState = .finished }
        
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
        guard page != totalPages else { return }
        
        viewState = .fetching
        defer { viewState = .finished }
        
        page += 1
        
        do {
            let result = try await interactor.getRecipes(page: page, perPage: perPage)
            recipes.append(contentsOf: result.items)
            totalPages = result.total
        } catch {
            hasError = true
            errorMessage = "Failed to fetch recipes"
        }
    }
    
    
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
        filteredPage = 1
        totalPages = 1
        filteredTotalPages = 1
        recipes = []
        filteredRecipes = []
    }
    
    func hasReachedEnd(recipe: RecipeListDTO) -> Bool {
        return isFiltered ? recipe.id == filteredRecipes.last?.id : recipe.id == recipes.last?.id
    }
}

// FILTERED LIST EXTENSION
extension RecipesVM {
    
    func filterRecipes(filters f: (String?, Int?, Int?, [Allergen]?)) async {
        
        resetFilters()
        viewState = .loading
        defer { viewState = .finished }
        
        do {
            let result = try await interactor.filterRecipes(name: f.0, minTime: f.1, maxTime: f.2, allergens: f.3, page: filteredPage, perPage: perPage)
            filters = f
            
            filteredRecipes = result.items
            filteredTotalPages = result.total
            isFiltered = true
        } catch {
            hasError = true
            errorMessage = "Failed to filter recipes"
        }
    }
    
    func resetFilters() {
        if viewState == .finished {
            filteredRecipes.removeAll()
            filteredPage = 1
            filteredTotalPages = nil
            viewState = nil
        }
    }
    
    func getNextFilteredRecipes() async {
        guard filteredPage != filteredTotalPages else { return }
        
        viewState = .fetching
        defer { viewState = .finished }
        
        filteredPage += 1
        
        do {
            let result = try await interactor.filterRecipes(name: filters.0, minTime: filters.1, maxTime: filters.2, allergens: filters.3, page: page, perPage: perPage)
            filteredRecipes.append(contentsOf: result.items)
            filteredTotalPages = result.total
        } catch {
            hasError = true
            errorMessage = "Failed to load new page of filtered recipes"
        }
    }
    
    func dismissFilter() {
        isFiltered = false
    }
}

extension RecipesVM {
    enum ViewState {
        case fetching
        case loading
        case finished
    }
    
    var isLoading: Bool {
        viewState == .loading
    }
    
    var isFetching: Bool {
        viewState == .fetching
    }
}

private extension RecipesVM {
    func reset() {
        if viewState == .finished {
            recipes.removeAll()
            page = 1
            totalPages = nil
            viewState = nil
        }
    }
}
