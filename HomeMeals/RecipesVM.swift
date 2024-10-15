import SwiftUI

@Observable
final class RecipesVM {
    private let interactor: DataInteractor
    
    var recipes: [RecipeListDTO] = []
    var ingredients: [IngredientDTO] = []
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
        Task {
            await getData()
        }
    }
    
    func getData() async {
//        async let ingredientsQuery = interactor.getIngredients(page: 1, perPage: 10)
        async let recipesQuery = interactor.getRecipes(page: 1, perPage: 10)
        
        do {
//            let (ingredientsResult, recipesResult) = try await (ingredientsQuery, recipesQuery)
            let recipesResult = try await recipesQuery
            await MainActor.run {
//                self.ingredients = ingredientsResult.items
                self.recipes = recipesResult.items
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func nextPage() async {
        
    }
}
