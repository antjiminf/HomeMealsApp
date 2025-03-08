import SwiftUI

@Observable
final class ShoppingListDetailVM {
    
    var list: GroceriesList
    var showConfirmationAlert: Bool = false
    
    var pendingItem: GroceriesModel?
    var showDeleteItemAlert: Bool = false
    
    init(_ list: GroceriesList) {
        self.list = list
    }
    
    var missingItems: [GroceriesModel] {
        list.items.filter { !$0.isObtained }
            .sorted { $0.name < $1.name }
    }
    var obtainedItems: [GroceriesModel] {
        list.items.filter { $0.isObtained }
            .sorted { $0.name < $1.name }
    }
    
    func toggleObtained(_ item: GroceriesModel) {
        item.isObtained.toggle()
    }
    
    func markAllAsMissing() {
        for item in list.items {
            item.isObtained = false
        }
    }
    
    func completeList() {
        list.items.forEach { $0.isObtained = true }
        list.isCompleted = true
    }
    
    func getSelectionIngredients() -> [SelectionIngredient] {
        list.items.map { i in
            SelectionIngredient(id: i.ingredientId,
                                name: i.name,
                                unit: i.unit,
                                quantity: i.requiredQuantity)
        }
    }
    
    func deleteItem(_ item: GroceriesModel) {
        if let index = list.items.firstIndex(of: item) {
            list.items.remove(at: index)
            pendingItem = nil
        }
    }
}
