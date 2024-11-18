import SwiftUI

@main
struct HomeMealsApp: App {
    @State var recipesVm = RecipesVM()
    @State var ingredientsVm = IngredientsVM()
    @State var inventoryVm = InventoryVM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(recipesVm)
                .environment(ingredientsVm)
                .environment(inventoryVm)
        }
    }
}
