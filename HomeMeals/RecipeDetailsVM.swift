import SwiftUI

@Observable
final class RecipeDetailsVM {
    var showEditForm: Bool = false
    var showDeleteConfirmation: Bool = false
    var recipe: RecipeDTO? = nil
    
    
}
