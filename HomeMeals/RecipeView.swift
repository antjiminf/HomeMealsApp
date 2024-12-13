import SwiftUI

struct RecipeView: View {
    @Environment(RecipesVM.self) var recipesVm
    @State private var showAddRecipe: Bool = false
    
    var body: some View {
        NavigationStack {
            List(recipesVm.recipes) { recipe in
                NavigationLink(value: recipe) {
                    Text(recipe.name)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddRecipe = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .refreshable {
                Task {
                    await recipesVm.getRecipes()
                }
            }
            .navigationTitle("Recipes")
            .navigationDestination(for: RecipeListDTO.self) { r in
                RecipeDetailsView(recipeId: r.id)
            }
            .fullScreenCover(isPresented: $showAddRecipe) {
                RecipeFormView(addRecipeVm: AddRecipeVM(),
                               title: "Create Recipe",
                               method: .CREATE)
            }
        }
    }
}

#Preview {
    RecipeView.preview
}
