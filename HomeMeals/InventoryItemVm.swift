import SwiftUI

@Observable
final class InventoryItemVm {
    
    let inventoryItem: InventoryItemDTO
    
    var quantity: Double
    
    init(inventoryItem: InventoryItemDTO) {
        self.inventoryItem = inventoryItem
        self.quantity = inventoryItem.quantity
    }
    
    func itemToEdit() -> ModifyInventoryItemDTO {
        return ModifyInventoryItemDTO(ingredient: inventoryItem.ingredientId,
                                      unit: inventoryItem.unit,
                                      quantity: quantity)
    }
}
