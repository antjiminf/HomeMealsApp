import SwiftUI

struct FavoriteRecipesView: View {
    
    @Environment(RecipesVM.self) var recipesVm
    
    var body: some View {
        
        NavigationStack {
            Group {
                if recipesVm.favoriteRecipes.isEmpty {
                    ContentUnavailableView("No favorite recipes",
                                           systemImage: "heart.slash",
                                           description: Text("No recipes marked as favorite! Tap the heart icon on recipes to add them to your favorites."))
                } else {
                    @Bindable var recipesBindable = recipesVm
                    ScrollView {
                        Group {
                            if recipesVm.searchedFavorites.isEmpty{
                                ContentUnavailableView("No coincidences",
                                                       systemImage: "exclamationmark.magnifyingglass",
                                                       description: Text("No favorite recipes found containing \"\(recipesVm.favoriteSearchText)\""))
                            } else {
                                ForEach(recipesVm.searchedFavorites) { recipe in
                                    NavigationLink {
                                        RecipeDetailsView(recipeDetailsVm: RecipeDetailsVM(recipeId: recipe.id))
                                    } label: {
                                        RecipeRow(recipe: recipe, listType: .favorite)
                                    }
                                }
                            }
                        }
                        .searchable(text: $recipesBindable.favoriteSearchText)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoriteRecipesView.preview
}
