import SwiftUI

@Observable
final class IngredientsVM {
    private let interactor: DataInteractor
    
    var ingredients: [IngredientDTO] = []
    var searchText: String = ""
    
    var filteredIngredients: [IngredientDTO] {
        ingredients.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var ingredientsByCategory: [FoodCategory: [IngredientDTO]] {
        Dictionary(grouping: filteredIngredients, by: { $0.category })
    }
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
        Task { await loadIngredients() }
    }
    
    func loadIngredients() async {
        do {
            self.ingredients = try await interactor.getAllIngredients()
        } catch {
            print(error.localizedDescription)
        }
    }
}
