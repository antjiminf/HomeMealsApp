import SwiftUI

@Observable
final class RecipeDetailsVM {
    private let interactor: DataInteractor
    
    let id: UUID
    var showEditForm: Bool = false
    var showDeleteConfirmation: Bool = false
    var showRecipeLikes: Bool = false
    var recipe: RecipeDTO?
    var likes: [UserLikeInfo] = []
    
    init(interactor: DataInteractor = Network.shared, recipeId: UUID) {
        self.interactor = interactor
        self.id = recipeId
        Task {
            await initRecipe()
        }
    }
    
    func initRecipe() async {
        do {
            recipe = try await interactor.getRecipeIngredients(id: id)
        } catch {
            
        }
    }
    
    func loadRecipeLikes() async {
        do {
            likes = try await interactor.getRecipeFavorites(id: id)
        } catch {
            
        }
    }
}
