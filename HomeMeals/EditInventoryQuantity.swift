import SwiftUI

struct EditQuantityView: View {
    @Environment(InventoryVM.self) var inventoryVm
    @State var inventoryItemVm: InventoryItemVm
    
    var body: some View {
        @Bindable var inventory = inventoryVm
        
        NavigationView {
            VStack(alignment: .center) {
                HStack() {
                    switch inventoryItemVm.inventoryItem.unit {
                    case .units:
                        TextField(
                            "Quantity",
                            value: $inventoryItemVm.quantity,
                            formatter: NumberFormatter()
                        )
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        
                        Stepper(value: $inventoryItemVm.quantity, step: 1) {}
                    default:
                        TextField(
                            "Quantity",
                            value: $inventoryItemVm.quantity,
                            formatter: NumberFormatter.decimalFormatter
                        )
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        
                        Stepper(value: $inventoryItemVm.quantity, step: 0.1) {}
                    }
                }
                .frame(width: 150)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        inventory.showingEditModal = false
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await inventoryVm.updateInventoryItem(
                                id: inventoryItemVm.inventoryItem.id,
                                updatedItem: inventoryItemVm.itemToEdit())
                            inventory.showingEditModal = false
                        }
                    }
                }
            }
            .navigationTitle(inventoryItemVm.inventoryItem.name)
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

#Preview {
    EditQuantityView.preview
}
