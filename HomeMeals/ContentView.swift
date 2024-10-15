import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RecipeView()
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife.circle.fill")
                }
            
        }
    }
}

#Preview {
    ContentView()
        .environment(RecipesVM(interactor: RecipeInteractorTest()))
}
