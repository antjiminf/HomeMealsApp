import SwiftUI

struct IngredientQuantity: View {
    let ingredientName: String
    @Binding var quantity: Int
    let unit: Unit
    
    var body: some View {
        HStack {
            if quantity > 0 {
                Button {
                    if quantity > 0 {
                        quantity = 0
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                        .frame(width: 20)
                        .bold()
                }
                .buttonStyle(BorderlessButtonStyle())
                .accessibilityHint(Text("Ingredient selected, tap here to discard"))
            }
            
            Text(ingredientName)
            Spacer()
            
            TextField(
                "Quantity",
                value: $quantity,
                formatter: NumberFormatter()
            )
            .foregroundStyle(quantity == 0 ? .gray : .black)
            .padding(5)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.secondarySystemBackground))
            }
            .keyboardType(.numberPad)
            .frame(width: 80)
            
            
            Text(unit.rawValue)
                .frame(width: 40, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    IngredientQuantity.preview
}
