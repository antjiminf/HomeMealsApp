import Foundation

struct Groceries: Codable {
    let ingredientId: UUID
    let name: String
    let requiredQuantity: Double
    let unit: Unit
}

struct InventoryItemDTO: Codable, Identifiable {
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
