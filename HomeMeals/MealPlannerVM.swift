import SwiftData
import SwiftUI

@Observable
final class MealPlannerVM {
    var selectedDate: Date = Date()
    var selectedMealType: MealType = .breakfast
    var showRecipeSelection = false
    var showDeleteMealPlanAlert = false
    var showDeleteMealAlert = false
    var isModifiableDate: Bool {
        Calendar.current.startOfDay(for: selectedDate) >= Calendar.current.startOfDay(for: Date())
    }
    
    func getMealPlan(for date: Date, in modelContext: ModelContext) -> MealPlanDay? {
        let normalizedDate = date.normalized
        let predicate = #Predicate<MealPlanDay> { $0.date == normalizedDate }
        let fetchDescriptor = FetchDescriptor<MealPlanDay>(predicate: predicate)
        
        return try? modelContext.fetch(fetchDescriptor).first
    }
    
    func addMeal(date: Date, mealType: MealType, recipe: RecipeListItem, in modelContext: ModelContext) {
        let normalizedDate = date.normalized
        do {
            let predicate = #Predicate<MealPlanDay> { $0.date == normalizedDate }
            let fetchDescriptor = FetchDescriptor<MealPlanDay>(predicate: predicate)
            let existingDayPlan = try modelContext.fetch(fetchDescriptor).first
            
            if let dayPlan = existingDayPlan {
                if let existingMealIndex = dayPlan.meals.firstIndex(where: { $0.type == mealType }) {
                    
                    let existingMeal = dayPlan.meals[existingMealIndex]
                    if existingMeal.recipeId == recipe.id {
                        return
                    }
                    
                    dayPlan.meals.remove(at: existingMealIndex)
                    try modelContext.save()
                }
                
                let newMeal = Meal(type: mealType, recipeId: recipe.id, recipeName: recipe.name)
                dayPlan.meals.append(newMeal)
                try modelContext.save()
            } else {
                let newDayPlan = MealPlanDay(date: normalizedDate, meals: [Meal(type: mealType, recipeId: recipe.id, recipeName: recipe.name)])
                modelContext.insert(newDayPlan)
            }
        } catch {
            print("Error editando el meal plan: \(error.localizedDescription)")
        }
    }
    
    func removeMeal(date: Date, mealType: MealType, in modelContext: ModelContext) {
        let normalizedDate = date.normalized
        do {
            if let dayPlan = getMealPlan(for: normalizedDate, in: modelContext),
               let mealIndex = dayPlan.meals.firstIndex(where: { $0.type == mealType }) {
                
                dayPlan.meals.remove(at: mealIndex)
                try modelContext.save()
            }
        } catch {
            print("Error eliminando la comida: \(error.localizedDescription)")
        }
    }
    
    func deleteMealPlan(date: Date, in modelContext: ModelContext) {
        let normalizedDate = date.normalized
        
        if let dayPlan = getMealPlan(for: normalizedDate, in: modelContext) {
            modelContext.delete(dayPlan)
        }
    }
    
    func cleanOldMealPlans(in modelContext: ModelContext) {
        let retentionDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())?.normalized ?? Date().normalized
        let predicate = #Predicate<MealPlanDay> { $0.date < retentionDate }
        let fetchDescriptor = FetchDescriptor<MealPlanDay>(predicate: predicate)
        
        do {
            let allPlans = try modelContext.fetch(fetchDescriptor)
            for plan in allPlans {
                modelContext.delete(plan)
            }
        } catch {
            print("Failed to clean old meal plans: \(error)")
        }
    }
    
}
