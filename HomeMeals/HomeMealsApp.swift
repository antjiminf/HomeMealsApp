import SwiftUI
import SwiftData

@main
struct HomeMealsApp: App {
    @State var recipesVm = RecipesVM()
    @State var ingredientsVm = IngredientsVM()
    @State var inventoryVm = InventoryVM()
    
    var sharedModelContainer: ModelContainer = {
            let schema = Schema([MealPlanDay.self, Meal.self])
            let container = try! ModelContainer(for: schema)
            return container
        }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(recipesVm)
                .environment(ingredientsVm)
                .environment(inventoryVm)
        }
        .modelContainer(for: MealPlanDay.self)
    }
}
