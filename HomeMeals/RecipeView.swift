import SwiftUI

struct RecipeView: View {
    @Environment(RecipesVM.self) var recipesVm
    var body: some View {
        NavigationStack {
            List(recipesVm.recipes) { recipe in
                Text(recipe.name)
            }
        }
    }
}

#Preview {
    RecipeView()
        .environment(RecipesVM(interactor: RecipeInteractorTest()))
}
