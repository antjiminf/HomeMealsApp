import SwiftData
import Foundation

@Model
final class MealPlanDay {
    @Attribute(.unique) var date: Date
    @Relationship(deleteRule: .cascade) var meals: [Meal] = []
    
    init(date: Date, meals: [Meal] = []) {
        self.date = date
        self.meals = meals
    }
}

@Model
final class Meal {
    var type: MealType
    var recipeId: UUID
    var recipeName: String
    
    init(type: MealType, recipeId: UUID, recipeName: String) {
        self.type = type
        self.recipeId = recipeId
        self.recipeName = recipeName
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast, lunch, dinner, snack
}
