import SwiftUI

struct RecipeRow: View {
    @Environment(RecipesVM.self) var recipesVm
    let recipe: RecipeListDTO
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack(spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        Task {
                            await recipesVm.softToggleFavorite(recipe: recipe.id)
                        }
                    } label: {
                        Image(systemName: "heart")
                            .symbolVariant(recipe.favorite ? .fill : .none)
                            .foregroundColor(.red)
                    }

                    Text(recipe.favTotal.formattedLikes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                }
                
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .imageScale(.small)
                    Text("\(recipe.time) min")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                if recipe.allergens.isEmpty {
                    AllergenFreeIndicator()
                } else {
                    HStack(spacing: 8) {
                        ForEach(recipe.allergens.prefix(5), id: \.self) { allergen in
                            Image(allergen.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                        }
                        
                        if recipe.allergens.count > 5 {
                            Text("+\(recipe.allergens.count - 5) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(5)
    }
}

#Preview {
    RecipeRow(recipe: .test)
        .environment(RecipesVM(interactor: InteractorTest()))
}
