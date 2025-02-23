import SwiftData
import SwiftUI

@Observable
final class ShoppingListGeneratorVM {
    private let interactor: DataInteractor
    
    var startDate: Date = Date()
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    
    var shoppingList: [Groceries] = []
    var ingredientsInList: [SelectionIngredient] = []
    var isLoading = false
    var generationToggled = false
    var showIngredientsSelector = false
    //    var isListModified = false
    
    var dateErrorMessage: String?
    var hasDateError: Bool { dateErrorMessage != nil }
    
    init(interactor: DataInteractor = Network.shared) {
        self.interactor = interactor
    }
    
    func validateDates() {
        if endDate < startDate {
            dateErrorMessage = "The end date cannot be before the start date."
        } else {
            dateErrorMessage = nil
        }
    }
    
    @MainActor
    func generateShoppingList(in modelContext: ModelContext) async {
        defer { isLoading = false }
        guard !hasDateError else { return }
        
        let predicate = #Predicate<MealPlanDay> { day in
            day.date >= startDate.normalized && day.date <= endDate.normalized
        }
        let fetchDescriptor = FetchDescriptor<MealPlanDay>(predicate: predicate)
        
        do {
            let mealPlans = try modelContext.fetch(fetchDescriptor)
            guard !mealPlans.isEmpty else {
                shoppingList = []
                generationToggled = true
                return
            }
            
            var recipeQuantities: [RecipeQuantity] = []
            for plan in mealPlans {
                for meal in plan.meals {
                    if let index = recipeQuantities.firstIndex(where: { $0.id == meal.recipeId }) {
                        recipeQuantities[index].quantity += 1
                    } else {
                        recipeQuantities.append(RecipeQuantity(id: meal.recipeId, quantity: 1))
                    }
                }
            }
            
            guard !recipeQuantities.isEmpty else {
                shoppingList = []
                generationToggled = true
                return
            }
            
            let totalIngredients = try await interactor.getTotalIngredientsInRecipes(recipes: recipeQuantities)
            let inventoryItems = totalIngredients.map { $0.toModifyInventoryItemDTO() }
            shoppingList = try await interactor.shoppingList(inventoryItems).sorted { $0.name < $1.name }
            generationToggled = true
            
        } catch {
            print("Error generating shopping list: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func saveShoppingList(in modelContext: ModelContext) async {
        guard !hasDateError else { return }
        
        if !generationToggled {
            await generateShoppingList(in: modelContext)
        }
        
        if shoppingList.isEmpty {
            //TODO: toggle de alerta o algo
        } else {
            let groceriesList = GroceriesList(
                startDate: startDate.normalized,
                endDate: endDate.normalized,
                items: shoppingList.map { $0.toGroceriesModel() }
            )
            modelContext.insert(groceriesList)
        }
    }
    
    func removeItem(at offsets: IndexSet) {
        //        isListModified = true
        shoppingList.remove(atOffsets: offsets)
    }
    
    func loadSelectedIngredients() {
        ingredientsInList = shoppingList.map { $0.toSelectionIngredient()}
    }
    
    func updateShoppingList() {
        isLoading = true
        defer { isLoading = false }
        
        shoppingList = ingredientsInList.map { ing in
            Groceries(ingredientId: ing.id,
                      name: ing.name,
                      requiredQuantity: ing.quantity,
                      unit: ing.unit)
        }.sorted { $0.name < $1.name }
    }
}
