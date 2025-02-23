import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MealPlannerView()
                .tabItem {
                    Label("Meal planner", systemImage: "calendar")
                }
            RecipeView()
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife.circle.fill")
                }
            FavoriteRecipesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "house.fill")
                }
            ShoppingListsView()
                .tabItem {
                    Label("Groceries", systemImage: "cart.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(RecipesVM(interactor: InteractorTest()))
        .environment(InventoryVM(interactor: InteractorTest()))
        .environment(IngredientsVM(interactor: InteractorTest()))
        .modelContainer(.testContainer)
}
