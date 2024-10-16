import SwiftUI

@main
struct HomeMealsApp: App {
    @State var recipesVm = RecipesVM()
    @State var ingredientsVm = IngredientsVM()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(recipesVm)
                .environment(ingredientsVm)
        }
    }
}
