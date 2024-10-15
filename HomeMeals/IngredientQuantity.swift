import SwiftUI

struct IngredientQuantity: View {
    let ingredientName: String
    @Binding var quantity: Double
    let unit: Unit
    
    @FocusState private var isFocused: Bool
    
    private var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    
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
            
            switch unit {
            case .volume:
                TextField(
                    "Quantity",
                    value: $quantity,
                    formatter: decimalFormatter
                )
                .foregroundStyle(quantity == 0 ? .gray : .black)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.secondarySystemBackground))
                }
                .keyboardType(.decimalPad)
                .frame(width: 80)
                .multilineTextAlignment(.trailing)
                .focused($isFocused)
                
                
                Text("L")
                    .frame(width: 40, alignment: .leading)
                
            case .units:
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
                .keyboardType(.decimalPad)
                .frame(width: 80)
                .multilineTextAlignment(.trailing)
                .focused($isFocused)
                
                Text("units")
                    .frame(width: 40, alignment: .leading)
                
            case .weight:
                TextField(
                    "Quantity",
                    value: $quantity,
                    formatter: decimalFormatter
                )
                .foregroundStyle(quantity == 0 ? .gray : .black)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.secondarySystemBackground))
                }
                .keyboardType(.decimalPad)
                .frame(width: 80)
                .multilineTextAlignment(.trailing)
                .focused($isFocused)
                
                Text("g")
                    .frame(width: 40, alignment: .leading)
                
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if quantity == 0 {
                quantity = 1.0
            }
            isFocused = true
        }
    }
}

#Preview {
    IngredientQuantity.preview
}
