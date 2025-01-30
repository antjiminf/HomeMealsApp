import Foundation
import SwiftData

@Model
final class GroceriesModel {
    @Attribute(.unique) var ingredientId: UUID
    var name: String
    var requiredQuantity: Double
    var unit: Unit
    
    init(ingredientId: UUID, name: String, requiredQuantity: Double, unit: Unit) {
        self.ingredientId = ingredientId
        self.name = name
        self.requiredQuantity = requiredQuantity
        self.unit = unit
    }
}

struct Groceries: Codable {
    let ingredientId: UUID
    let name: String
    let requiredQuantity: Double
    let unit: Unit
}

struct InventoryItem: Codable, Identifiable {
    let id: UUID
    let ingredientId: UUID
    let name: String
    let unit: Unit
    let quantity: Double
}

struct ModifyInventoryItemDTO: Codable {
    let ingredient: UUID
    let unit: Unit
    let quantity: Double
}
