import SwiftUI

struct SuggestedRecipesList: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RecipesVM.self) var recipesVm: RecipesVM
    
    var body: some View {
        NavigationStack {
            Group {
                if !recipesVm.suggestedRecipes.isEmpty {
                    ScrollView {
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top) {
                                    ForEach(recipesVm.suggestedRecipes) { recipe in
                                        NavigationLink(destination: RecipeDetailsView(recipeDetailsVm: RecipeDetailsVM(recipeId: recipe.id))) {
                                            RecipeCard(recipe: recipe)
                                        }
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                            .contentMargins(20, for: .scrollContent)
                            .listRowInsets(EdgeInsets())
                        } header: {
                            HStack {
                                Text("Matching your current inventory")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                                    .bold()
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                        }
                        .listRowSeparator(.hidden)
                    }
                } else {
                    ContentUnavailableView("No suggestions",
                                           systemImage: "cart.fill",
                                           description: Text("We couldn't find any recipe suggestions for you right now. Please check back later when you have more ingredients in your inventory."))
                }
            }
            .navigationTitle("Recipe Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SuggestedRecipesList.preview
}
