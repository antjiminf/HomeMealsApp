import SwiftUI

@Observable
final class RecipesVM {
    private let interactor: DataInteractor
    
    var recipes: [RecipeListDTO] = []
    var ingredients: [IngredientDTO] = []
    var hasError: Bool = false
    var errorMessage: String?
    
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
        Task {
            await getRecipes()
        }
    }
    
    func getRecipes() async {
//        async let ingredientsQuery = interactor.getIngredients(page: 1, perPage: 10)
        async let recipesQuery = interactor.getRecipes(page: 1, perPage: 20)
        
        do {
//            let (ingredientsResult, recipesResult) = try await (ingredientsQuery, recipesQuery)
            let recipesResult = try await recipesQuery
            await MainActor.run {
//                self.ingredients = ingredientsResult.items
                self.recipes = recipesResult.items
            }
        } catch {
            hasError = true
            errorMessage = "Failed to fetch recipes"
        }
    }
    
    func addRecipe(_ new: CreateRecipeDTO) async {
        do {
            try await interactor.addRecipe(new)
            await getRecipes()
        } catch {
            print(error.localizedDescription)
            hasError = true
            errorMessage = error.localizedDescription
//            errorMessage = "Failed to create recipe"
        }
    }
    
    func nextPage() async {
        
    }
}
