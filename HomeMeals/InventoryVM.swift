import SwiftUI

@Observable
final class InventoryVM {
    private let interactor: DataInteractor
    
    var inventory: [InventoryItemDTO] = []
    var searchText: String = ""
    
    var filteredInventory: [InventoryItemDTO] {
        inventory.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
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
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteInventoryItem(id: UUID) async {
        do {
            try await interactor.deleteInventoryItem(id)
        } catch {
            print(error.localizedDescription)
        }
    }
}
