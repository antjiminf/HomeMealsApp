import SwiftUI

struct RecipeDetailsView: View {
    @Environment(RecipesVM.self) var recipesVm
    @Environment(\.dismiss) var dismiss
    @State var recipeDetailsVm: RecipeDetailsVM
    
    func loadRecipe() -> Void {
        Task {
            recipeDetailsVm.recipe = await recipesVm.getRecipeDetails(id: recipeDetailsVm.id)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let recipe = recipeDetailsVm.recipe {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Descripción
                            if !recipe.description.isEmpty {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                        .shadow(color: Color.black.opacity(0.1), radius: 2)
                                    Text(recipe.description)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .padding()
                                }
                                .padding(.bottom, 12)
                            }
                            
                            // Likes y Tiempo de Preparación
                            HStack {
                                //Likes
                                HStack {
                                    Button {
                                        Task {
                                            await recipesVm.toggleFavorite(recipe: recipe.id)
                                            loadRecipe()
                                        }
                                    } label: {
                                        Image(systemName: recipe.favorite ? "heart.fill" : "heart")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                    }
                                    
                                    Button {
                                        recipeDetailsVm.showRecipeLikes = true
                                    } label: {
                                        Text("\(recipe.favTotal.formattedLikes) likes")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .disabled(recipe.favTotal == 0)
                                }
                                
                                Spacer()
                                
    //                             Tiempo de Preparación
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                    Text("\(recipe.time) min")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                            
                            // Alérgenos
                            if !recipe.allergens.isEmpty {
                                Section(header: Text("Allergens").font(.headline).bold()) {
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 20))], spacing: 8) {
                                        ForEach(recipe.allergens, id: \.self) { allergen in
                                            Image(allergen.rawValue)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                }
                                .padding(.bottom, 12)
                            } else {
                                AllergenFreeIndicator()
                            }
                            
                            Divider()
                            
                            // Ingredientes
                            Section(header: Text("Ingredients").font(.headline).bold()) {
                                ForEach(recipe.ingredients.sorted(by: { $0.name < $1.name }), id: \.self) { ingredient in
                                    HStack {
                                        Text(ingredient.name)
                                        Spacer()
                                        
                                        switch ingredient.unit {
                                            
                                            case .units:
                                            Text("\(ingredient.quantity, specifier: "%.0f") units")
                                                .foregroundColor(.secondary)
                                            
                                            case .volume:
                                            
                                            Text("\(ingredient.quantity, specifier: "%.1f") L")
                                                .foregroundColor(.secondary)
                                            
                                            case .weight:
                                                Text("\(ingredient.quantity, specifier: "%.1f") g")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Guía de Preparación
                            Section(header: Text("Guide").font(.headline).bold()) {
                                ForEach(recipe.guide.indices, id: \.self) { index in
                                    Text("\(index + 1). \(recipe.guide[index])")
                                        .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationTitle(recipe.name)
                    .toolbar {
                        // Editar y Eliminar
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Edit") {
                                recipeDetailsVm.showEditForm = true
                            }
                            .accessibility(label: Text("Edit Recipe"))
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(role: .destructive) {
                                recipeDetailsVm.showDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                                    .tint(.red)
                            }
                            .accessibility(label: Text("Delete Recipe"))
                        }
                    }
                    .sheet(isPresented: $recipeDetailsVm.showEditForm) {
                        RecipeFormView(
                            addRecipeVm: AddRecipeVM(recipe: recipeDetailsVm.recipe),
                            title: "Edit Recipe",
                            method: .UPDATE,
                            onUpdate: loadRecipe
                        )
                    }
                    .sheet(isPresented: $recipeDetailsVm.showRecipeLikes) {
                        UsersLikesList(recipeDetailsVm: recipeDetailsVm)
                    }
                    .alert("Delete Recipe", isPresented: $recipeDetailsVm.showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            Task {
                                await recipesVm.deleteRecipe(id: recipe.id)
                                dismiss()
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                } else {
                    ProgressView("Loading recipe...")
                }
            }
        }
    }
}


#Preview {
    RecipeDetailsView.preview
}
