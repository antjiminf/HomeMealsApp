import SwiftUI

struct EditQuantityView: View {
    @Environment(InventoryVM.self) var inventoryVm
    @Environment(\.dismiss) var dismiss
    @State var inventoryItemVm: InventoryItemVM
    let onUpdate: () async -> Void
    
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
                        
                        Stepper(value: $inventoryItemVm.quantity, in: 0...Double.infinity, step: 1) {}
                    default:
                        TextField(
                            "Quantity",
                            value: $inventoryItemVm.quantity,
                            formatter: NumberFormatter.decimalFormatter
                        )
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        
                        Stepper(value: $inventoryItemVm.quantity, in: 0.0...Double.infinity, step: 0.1) {}
                    }
                }
                .frame(width: 150)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let id = inventoryItemVm.inventoryItem.id
                            
                            if let updated = inventoryItemVm.itemToEdit() {
                                await inventoryVm.updateInventoryItem(id: id, updatedItem: updated)
                            } else {
                                await inventoryVm.deleteInventoryItem(id: id)
                            }
                            await onUpdate()
                            dismiss()
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
