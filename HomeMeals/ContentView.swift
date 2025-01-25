import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
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
        }
    }
}

#Preview {
    ContentView()
        .environment(RecipesVM(interactor: InteractorTest()))
        .environment(InventoryVM(interactor: InteractorTest()))
        .environment(IngredientsVM(interactor: InteractorTest()))
}
