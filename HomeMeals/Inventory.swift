import Foundation
import SwiftData


@Model
final class GroceriesList {
    @Attribute(.unique) var id: UUID = UUID()
    var startDate: Date
    var endDate: Date
    var createdAt: Date = Date()
    var isCompleted: Bool = false
    
    @Relationship(deleteRule: .cascade) var items: [GroceriesModel] = []
    
    init(startDate: Date, endDate: Date, items: [GroceriesModel]) {
        self.startDate = startDate
        self.endDate = endDate
        self.items = items
    }
}

@Model
final class GroceriesModel {
    @Attribute(.unique) var id: UUID = UUID()
    var ingredientId: UUID
    var name: String
    var requiredQuantity: Int
    var unit: Unit
    var isObtained: Bool = false
    
    init(ingredientId: UUID, name: String, requiredQuantity: Int, unit: Unit) {
        self.ingredientId = ingredientId
        self.name = name
        self.requiredQuantity = requiredQuantity
        self.unit = unit
    }
}

struct Groceries: Codable, Identifiable {
    let ingredientId: UUID
    let name: String
    var requiredQuantity: Int
    let unit: Unit
    
    func toModifyInventoryItemDTO() -> ModifyInventoryItemDTO {
        return .init(ingredient: ingredientId, unit: unit, quantity: requiredQuantity)
    }
    
    func toGroceriesModel() -> GroceriesModel {
        return .init(ingredientId: ingredientId, name: name, requiredQuantity: requiredQuantity, unit: unit)
    }
    
    func toSelectionIngredient() -> SelectionIngredient {
        .init(id: ingredientId, name: name, unit: unit, quantity: requiredQuantity)
    }
    
    var id: UUID { ingredientId }
}

struct InventoryItem: Codable, Identifiable {
    let id: UUID
    let ingredientId: UUID
    let name: String
    let unit: Unit
    let quantity: Int
}

struct ModifyInventoryItemDTO: Codable {
    let ingredient: UUID
    let unit: Unit
    let quantity: Int
}
