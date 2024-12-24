import SwiftUI

struct RecipeView: View {
    @Environment(RecipesVM.self) var recipesVm
    @State private var showAddRecipe: Bool = false
    
    var body: some View {
        @Bindable var recipesVmBindable = recipesVm
        
        NavigationStack {
            List {
                if !recipesVm.suggestedRecipes.isEmpty {
                    Section(header: Text("Suggested Recipes").font(.title2).bold()) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(recipesVm.suggestedRecipes) { recipe in
                                    NavigationLink(value: recipe) {
                                        RecipeCard(recipe: recipe)
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .contentMargins(20, for: .scrollContent)
                        .listRowInsets(EdgeInsets())
                    }
                    .listRowSeparator(.hidden)
                    .headerProminence(.increased)
                }
                Section(header: Text("All Recipes").font(.title2).bold()) {
                    ScrollView {
                        LazyVStack {
                            ForEach(recipesVm.recipes, id: \.id) { recipe in
                                RecipeRow(recipe: recipe)
    //                                .task {
    //                                    if recipesVm.hasReachedEnd(recipe: recipe) && !recipesVm.isLoadingPage {
    //                                        await recipesVm.getNextRecipes()
    //                                    }
    //                                }
                            }
                            
                            if recipesVm.isLoadingPage {
                                HStack {
                                    ProgressView()
                                    Text("Loading more recipes...")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                            }
                        }
                    }.scrollTargetBehavior(.viewAligned)
                }
                .listRowSeparator(.hidden)
            }
            .searchable(text: $recipesVmBindable.search)
            .listStyle(.plain)
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
            .navigationTitle("Recipes Explorer")
            .navigationBarTitleDisplayMode(.inline)
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

struct RecipeRow: View {
    let recipe: RecipeListDTO
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.name)
                .font(.headline)
            Text(recipe.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    RecipeView.preview
}
