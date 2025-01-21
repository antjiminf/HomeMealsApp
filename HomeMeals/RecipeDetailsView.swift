import SwiftUI

struct RecipeDetailsView: View {
    @Environment(RecipesVM.self) var recipesVm
    @Environment(\.dismiss) var dismiss
    let recipeId: UUID
    @State var recipeDetailsVm = RecipeDetailsVM()
    
    func loadRecipe() -> Void {
        Task {
            recipeDetailsVm.recipe = await recipesVm.getRecipeDetails(id: recipeId)
        }
    }
    
    var body: some View {
        Group {
            if let recipe = recipeDetailsVm.recipe {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Section {
                            if !recipe.description.isEmpty {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                        .shadow(color: Color.black.opacity(0.1),
                                                radius: 2)
                                    Text(recipe.description)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .bold()
                                        .padding()
                                }
                                .padding(.bottom, 12)
                            }
                            
                            HStack(alignment: .center) {
                                HStack(spacing: 8) {
                                    if recipe.allergens.isEmpty {
                                        AllergenFreeIndicator()
                                    } else {
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 20))],
                                                  spacing: 8) {
                                            ForEach(recipe.allergens, id: \.self) { allergen in
                                                Image(allergen.rawValue)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                            }
                                        }.frame(maxWidth: 150)
                                    }
                                }
                                .frame(width: 150)
                                Spacer()
                                Text("Preparation Time: \(recipe.time) min")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        Section(header: Text("Ingredients").font(.title2).bold()) {
                            ForEach(recipe.ingredients.sorted(by: { $0.name < $1.name }),
                                    id: \.self) { ingredient in
                                HStack {
                                    Text(ingredient.name)
                                    Spacer()
                                    Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit.rawValue)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        Section(header: Text("Guide").font(.title2).bold()) {
                            ForEach(recipe.guide.indices, id: \.self) { index in
                                Text("\(index + 1). \(recipe.guide[index])")
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom)
                }
                .navigationTitle(recipe.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            recipeDetailsVm.showEditForm = true
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            recipeDetailsVm.showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .tint(.red)
                        }
                    }
                }
                .sheet(isPresented: $recipeDetailsVm.showEditForm) {
                    RecipeFormView(addRecipeVm: AddRecipeVM(recipe: recipeDetailsVm.recipe),
                                   title: "Edit Recipe",
                                   method: .UPDATE,
                                   onUpdate: loadRecipe)
                }
                .alert("Delete Recipe", isPresented: $recipeDetailsVm.showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        Task {
                            await recipesVm.deleteRecipe(id: recipeId)
                            dismiss()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            } else {
                ProgressView("Loading recipe...")
                    .onAppear {
                        loadRecipe()
                    }
            }
        }
    }
}

#Preview {
    RecipeDetailsView.preview
}
