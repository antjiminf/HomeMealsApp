import SwiftUI

struct RecipeCard: View {
    let recipe: RecipeListItem
    private let cardHeight: CGFloat = 120

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text(recipe.name)
                    .font(.headline)
                    .bold()
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                Text("Time: \(recipe.time) min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if recipe.allergens.isEmpty {
                    Text("Allergen Free")
                        .font(.footnote)
                        .foregroundColor(.green)
                        .bold()
                } else {
                    HStack(spacing: 4) {
                        ForEach(recipe.allergens.prefix(3), id: \.self) { allergen in
                            Image(allergen.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        if recipe.allergens.count > 3 {
                            Text("and \(recipe.allergens.count - 3) more")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Spacer()

            Image(systemName: "fork.knife")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
        }
        .padding(15)
        .containerRelativeFrame(.horizontal)
        .frame(height: cardHeight)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        )
    }
}

#Preview {
    RecipeCard(recipe: .test)
}
