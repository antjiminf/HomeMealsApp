import SwiftUI

@Observable
final class RecipeDetailsVM {
    private let interactor: DataInteractor
    
    var showEditForm: Bool = false
    var showDeleteConfirmation: Bool = false
    var showRecipeLikes: Bool = false
    var recipe: RecipeDTO? = nil
    var likes: [UserLikeInfo] = []
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
    }
    
    func loadRecipeLikes() async {
        guard let recipe = self.recipe else { return }
        do {
            likes = try await interactor.getRecipeFavorites(id: recipe.id)
        } catch {
            
        }
    }
}
