import SwiftUI

struct RecipeView: View {
    @Environment(RecipesVM.self) var recipesVm
    var body: some View {
        NavigationStack {
            List(recipesVm.recipes) { recipe in
                Text(recipe.name)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddRecipeView()) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
        
    }
}

#Preview {
    RecipeView()
        .environment(RecipesVM(interactor: RecipeInteractorTest()))
}
