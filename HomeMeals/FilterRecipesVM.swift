import SwiftUI

@Observable
final class FilterRecipesVM {
    private let interactor: DataInteractor
    
    var minTime: Int = 0
    var maxTime: Int = 240
    var allergens: [Allergen] = []
    
    var filteredRecipes: [RecipeListDTO] = []
    
    private var page: Int = 1
    private var totalPages: Int = 1
    
    private var perPage: Int = 20
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
    }
    
    func filterRecipes() async {
        do {
            let result = try await interactor.filterRecipes(minTime: minTime, maxTime: maxTime, allergens: allergens, page: page, perPage: perPage)
            filteredRecipes = result.items
            totalPages = result.total
            page += 1
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
}
