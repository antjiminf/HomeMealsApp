import SwiftUI

@Observable
final class InventoryVM {
    private let interactor: DataInteractor
    
    var inventory: [InventoryItem] = []
    var searchText: String = ""
    var filteredInventory: [InventoryItem] {
        inventory.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    var shoppingList: [Groceries] = []
//    var ingredients: [SelectionIngredient] {
//        inventory.map { i in
//            SelectionIngredient(id: i.ingredientId,
//                                name: i.name,
//                                unit: i.unit,
//                                quantity: i.quantity)
//        }
//    }
    
    var editingItem: InventoryItem?
    var showingEditModal: Bool = false
    
    var showingDeleteConfirmation: Bool = false
    var pendingItem: InventoryItem?

    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
        Task { await loadInventory() }
    }
    
    func loadInventory() async {
        do {
            self.inventory = try await interactor.getInventory()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateInventoryItem(id: UUID, updatedItem: ModifyInventoryItemDTO) async {
        do {
            try await interactor.updateInventoryItem(id: id, item: updatedItem)
            await loadInventory()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteInventoryItem(id: UUID) async {
        do {
            try await interactor.deleteInventoryItem(id)
            pendingItem = nil
            await loadInventory()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateInventory(items: [SelectionIngredient]) async {
        do {
            try await interactor.updateInventory(items.map { i in
                ModifyInventoryItemDTO(ingredient: i.id,
                                       unit: i.unit,
                                       quantity: i.quantity)
            })
            await loadInventory()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addGroceries(groceries: [SelectionIngredient]) async {
        do {
            try await interactor.addGroceries(groceries.map { i in
                ModifyInventoryItemDTO(ingredient: i.id,
                                       unit: i.unit,
                                       quantity: i.quantity)
            })
            await loadInventory()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func consumeGroceries(groceries: [SelectionIngredient]) async {
        do {
            try await interactor.consumeGroceries(groceries.map { i in
                ModifyInventoryItemDTO(ingredient: i.id,
                                       unit: i.unit,
                                       quantity: i.quantity)
            })
            await loadInventory()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getShoppingList(ingredients: [ModifyInventoryItemDTO]) async {
        do {
            shoppingList = try await interactor.shoppingList(ingredients)
        } catch {
            print(error.localizedDescription)
        }
    }
}
