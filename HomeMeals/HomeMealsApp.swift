import SwiftUI
import SwiftData

@main
struct HomeMealsApp: App {
    @State var userVm = UserVM()
    @State var recipesVm = RecipesVM()
    @State var ingredientsVm = IngredientsVM()
    @State var inventoryVm = InventoryVM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(userVm)
                .environment(recipesVm)
                .environment(ingredientsVm)
                .environment(inventoryVm)
        }
        .modelContainer(for: [MealPlanDay.self, GroceriesList.self])
    }
}
