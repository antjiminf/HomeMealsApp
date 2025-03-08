import SwiftUI

enum ListType {
    case recipes
    case favorite
}

struct RecipeRow: View {
    @Environment(RecipesVM.self) var recipesVm
    let recipe: RecipeListItem
    var listType: ListType = .recipes
//    @State var showDeleteAlert: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack(spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    //                    Button {
                    //                        if listType == .favorite {
                    //                            showDeleteAlert = true
                    //                        } else {
                    //                            Task {
                    //                                await recipesVm.softToggleFavorite(recipe: recipe.id)
                    //                            }
                    //                        }
                    //                    } label: {
                    Image(systemName: "heart")
                        .symbolVariant(recipe.favorite ? .fill : .none)
                        .foregroundColor(.red)
                    //                    }
                    //                    .buttonStyle(.plain)
                    //                    .contentShape(Rectangle())
                    
                    Text(recipe.favTotal.formattedLikes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
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
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(5)
//        .alert("Remove Favorite", isPresented: $showDeleteAlert) {
//            Button("Delete", role: .destructive) {
//                Task {
//                    await recipesVm.softToggleFavorite(recipe: recipe.id)
//                }
//            }
//            Button("Cancel", role: .cancel) {}
//        } message: {
//            Text("Are you sure you want to remove this recipe from your favorites?")
//        }
        .contextMenu {
            Button {
                Task {
                    await recipesVm.softToggleFavorite(recipe: recipe.id)
                }
            } label: {
                if recipe.favorite {
                    Label("Remove from favorites", systemImage: "heart.fill")
                } else {
                    Label("Add to favorites", systemImage: "heart")
                }
            }
        }
    }
}

#Preview {
    RecipeRow(recipe: .test, listType: .favorite)
        .environment(RecipesVM(interactor: InteractorTest()))
}
