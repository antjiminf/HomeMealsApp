import SwiftUI

struct RecipeView: View {
    @Environment(RecipesVM.self) var recipesVm
    @State private var showAddRecipe: Bool = false
    @State private var showFilters: Bool = false
    
    var body: some View {
        //        @Bindable var recipesVmBindable = recipesVm
        NavigationStack {
            VStack {
                if recipesVm.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack {
                            if recipesVm.isFiltered {
                                ForEach(recipesVm.filteredRecipes, id: \.id) { recipe in
                                    NavigationLink {
                                        RecipeDetailsView(recipeId: recipe.id)
                                    } label: {
                                        RecipeRow(recipe: recipe)
                                            .task {
                                                if recipesVm.hasReachedEnd(recipe: recipe),
                                                   !recipesVm.isFetching {
                                                    await recipesVm.getNextFilteredRecipes()
                                                }
                                            }
                                    }
                                }
                            } else {
                                ForEach(recipesVm.recipes, id: \.id) { recipe in
                                    NavigationLink {
                                        RecipeDetailsView(recipeId: recipe.id)
                                    } label: {
                                        RecipeRow(recipe: recipe)
                                            .task {
                                                if recipesVm.hasReachedEnd(recipe: recipe),
                                                   !recipesVm.isFetching {
                                                    await recipesVm.getNextRecipes()
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .overlay(alignment: .bottom) {
                        if recipesVm.isFetching {
                            ProgressView()
                        }
                    }
                    .refreshable {
                        if !recipesVm.isFiltered {
                            await recipesVm.initRecipes()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAddRecipe = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .imageScale(.large)
                    }
                }
                if recipesVm.isFiltered {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            recipesVm.dismissFilter()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                        }
                    }
                }
            }
            .navigationTitle("Recipes Explorer")
            //            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: RecipeListDTO.self) { r in
                RecipeDetailsView(recipeId: r.id)
            }
            .fullScreenCover(isPresented: $showAddRecipe) {
                RecipeFormView(addRecipeVm: AddRecipeVM(),
                               title: "Create Recipe",
                               method: .CREATE)
            }
            .fullScreenCover(isPresented: $showFilters) {
                FilterRecipesView(filterVm: FilterRecipesVM())
            }
        }
    }
}

#Preview {
    RecipeView.preview
}
