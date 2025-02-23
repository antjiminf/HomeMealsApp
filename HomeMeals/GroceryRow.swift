import SwiftUI

struct GroceryRow: View {
    @Bindable var item: GroceriesModel
    let toggleObtained: (GroceriesModel) -> Void
    
    var body: some View {
        HStack {
            ViewThatFits(in: .horizontal) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                    Spacer()
                    
                    TextField("Quantity", value: $item.requiredQuantity, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 60, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .disabled(item.isObtained)
                    
                    Text(item.unit.rawValue)
                        .frame(width: 40, alignment: .leading)
                }
                
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    
                    HStack {
                        TextField("Quantity", value: $item.requiredQuantity, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 60, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .disabled(item.isObtained)
                        
                        Text(item.unit.rawValue)
                            .frame(width: 40, alignment: .leading)
                    }
                }
            }
            Spacer()
            Stepper(value: $item.requiredQuantity,
                    in: item.unit == .units ? 1...Double.infinity : 0.1...Double.infinity,
                    step: item.unit == .units ? 1 : 0.1) {
                EmptyView()
            }
            .disabled(item.isObtained)
            .fixedSize()
            
            Button {
                toggleObtained(item)
            } label:  {
                Image(systemName: item.isObtained ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isObtained ? .green : .gray)
            }
            .buttonStyle(.plain)
            .font(.title2)
            
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    GroceryRow.preview
}
