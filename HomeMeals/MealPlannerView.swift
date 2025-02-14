import SwiftUI
import SwiftData

struct MealPlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealPlanDay.date) var mealPlans: [MealPlanDay]
    @State var mealPlanner = MealPlannerVM()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DatePicker("Select Date", selection: $mealPlanner.selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                    
                    VStack(spacing: 20) {
                        let dayPlan = mealPlanner.getMealPlan(for: mealPlanner.selectedDate, in: modelContext)
                        
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            HStack {
                                Text(mealType.rawValue.capitalized)
                                    .font(.headline)
                                    .frame(width: 120, alignment: .leading)
                                
                                Spacer()
                                
                                if let meal = dayPlan?.meals.first(where: { $0.type == mealType }) {
                                    Text(meal.recipeName)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("No recipe selected")
                                        .italic()
                                        .foregroundColor(.gray)
                                }
                                
                                if mealPlanner.isModifiableDate {
                                    Menu {
                                        Button("Change Recipe") {
                                            mealPlanner.selectedMealType = mealType
                                            mealPlanner.showRecipeSelection = true
                                        }
                                        
                                        if let dayPlan,
                                           let meal = dayPlan.meals.first(where: { $0.type == mealType }) {
                                            Button("Remove Meal", role: .destructive) {
                                                mealPlanner.selectedMealType = meal.type
                                                mealPlanner.showDeleteMealAlert = true
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .foregroundColor(.blue)
                                            .imageScale(.medium)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                        }
                        
                        if let dayPlan {
                            Button("Delete Plan for \(dayPlan.date.dateFormatter)", role: .destructive) {
                                mealPlanner.showDeleteMealPlanAlert = true
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Meal Planner")
            .sheet(isPresented: $mealPlanner.showRecipeSelection) {
                RecipeSelectionView(mealPlanner: mealPlanner)
            }
            .alert("Delete Meal?", isPresented: $mealPlanner.showDeleteMealAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let dayPlan = mealPlanner.getMealPlan(for: mealPlanner.selectedDate, in: modelContext) {
                        mealPlanner.removeMeal(date: dayPlan.date, mealType: mealPlanner.selectedMealType, in: modelContext)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this meal?")
            }
            .alert("Delete Meal Plan?", isPresented: $mealPlanner.showDeleteMealPlanAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let dayPlan = mealPlanner.getMealPlan(for: mealPlanner.selectedDate, in: modelContext) {
                        mealPlanner.deleteMealPlan(date: dayPlan.date, in: modelContext)
                    }
                }
            } message: {
                Text("This will remove all meals for the selected day. Are you sure?")
            }
            .onAppear {
                mealPlanner.cleanOldMealPlans(in: modelContext)
            }
        }
    }
}


#Preview {
    let meals = [
        Meal(type: .breakfast, recipeId: UUID(), recipeName: "Pancakes"),
        Meal(type: .lunch, recipeId: UUID(), recipeName: "Grilled Chicken Salad"),
        Meal(type: .dinner, recipeId: UUID(), recipeName: "Spaghetti Bolognese"),
        Meal(type: .snack, recipeId: UUID(), recipeName: "Greek Yogurt with Berries"),
        Meal(type: .lunch, recipeId: UUID(), recipeName: "Avocado Toast"),
        Meal(type: .dinner, recipeId: UUID(), recipeName: "Salmon with Quinoa")
    ]
    
    let mealPlans = [
        MealPlanDay(date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!.normalized, meals: [meals[0], meals[1], meals[2]]),
        MealPlanDay(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!.normalized, meals: [meals[3], meals[4]]),
        MealPlanDay(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!.normalized, meals: [meals[5]])
    ]
    
    MealPlannerView()
        .environment(RecipesVM(interactor: InteractorTest()))
        .modelContainer(for: MealPlanDay.self, inMemory: true) { result in
            if case .success(let container) = result {
                for mealPlan in mealPlans {
                    container.mainContext.insert(mealPlan)
                }
            }
        }
}
