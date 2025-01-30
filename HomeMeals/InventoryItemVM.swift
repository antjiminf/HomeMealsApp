import SwiftUI

@Observable
final class InventoryItemVM {
    
    let inventoryItem: InventoryItem
    
    var quantity: Double
    
    init(inventoryItem: InventoryItem) {
        self.inventoryItem = inventoryItem
        self.quantity = inventoryItem.quantity
    }
    
    func itemToEdit() -> ModifyInventoryItemDTO? {
        if quantity < 0.1 {
            return nil
        }
        return ModifyInventoryItemDTO(ingredient: inventoryItem.ingredientId,
                                      unit: inventoryItem.unit,
                                      quantity: quantity)
    }
}
