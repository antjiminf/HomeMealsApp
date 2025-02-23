import SwiftUI

struct InventoryView: View {
    @Environment(InventoryVM.self) var inventoryVm
    @Environment(RecipesVM.self) var recipesVm
    @State var detent: PresentationDetent = .fraction(0.25)
    @State var ingredients: [SelectionIngredient] = []
    @State var showAddIngredients = false
    @State var showConsumeIngredients = false
    @State var showSuggestedRecipes = false
    
    var body: some View {
        @Bindable var inventory = inventoryVm
        
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search ingredients...", text: $inventory.searchText)
                    
                    if !inventory.searchText.isEmpty {
                        Button {
                            inventory.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Delete current value.")
                    }
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.secondarySystemBackground))
                }
                .padding([.horizontal, .bottom])
                
                HStack(spacing: 10) {
                    Button {
                        showSuggestedRecipes = true
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.rectangle.portrait.fill")
                                .font(.title2)
                            Text("For you")
                        }
                    }
                    .accessibilityLabel("Suggested Recipes")
                    
                    Spacer()
                    
                    Button {
                        showAddIngredients = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .accessibilityLabel("Add Ingredients")
                    
                    Button {
                        showConsumeIngredients = true
                    } label: {
                        
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    .accessibilityLabel("Consume Ingredients")
                }
                .padding(.horizontal, 20)
                
                Group {
                    if !inventoryVm.filteredInventory.isEmpty {
                        List {
                            ForEach(inventoryVm.filteredInventory.sorted(by: { $0.name < $1.name })) { item in
                                HStack {
                                    Text(item.name)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    switch item.unit {
                                    case .units:
                                        Text("\(item.quantity, specifier: "%.0f") units")
                                            .foregroundColor(.secondary)
                                    case .weight:
                                        Text("\(item.quantity, specifier: "%.1f") g")
                                            .foregroundColor(.secondary)
                                    case .volume:
                                        Text("\(item.quantity, specifier: "%.1f") L")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Button {
                                        inventoryVm.editingItem = item
                                        inventoryVm.showingEditModal = true
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        inventoryVm.pendingItem = item
                                        inventoryVm.showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "No coincidences",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text("No ingredients found containing \"\(inventoryVm.searchText)\""))
                        .background(Color(uiColor: .systemGray6))
                    }
                }
                .refreshable {
                    await inventoryVm.loadInventory()
                }
            }
            .sheet(isPresented: $inventory.showingEditModal) {
                if let item = inventoryVm.editingItem {
                    EditQuantityView(inventoryItemVm: InventoryItemVM(inventoryItem: item),
                                     onUpdate: recipesVm.inventoryUpdated)
                    .environment(inventoryVm)
                    .presentationDetents([.fraction(0.25), .medium], selection: $detent)
                }
            }
            .fullScreenCover(isPresented: $showAddIngredients) {
                IngredientsSelector(
                    selectorVM: IngredientSelectorVM(),
                    selectedIngredients: $ingredients,
                    title: "Add Groceries")
                .onDisappear {
                    if !ingredients.isEmpty {
                        Task {
                            await inventoryVm.addGroceries(groceries: ingredients)
                            ingredients = []
                            await recipesVm.inventoryUpdated()
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showConsumeIngredients) {
                IngredientsSelector(
                    selectorVM: IngredientSelectorVM(),
                    selectedIngredients: $ingredients,
                    title: "Consume Groceries")
                .onDisappear {
                    if !ingredients.isEmpty {
                        Task {
                            await inventoryVm.consumeGroceries(groceries: ingredients)
                            ingredients = []
                            await recipesVm.inventoryUpdated()
                        }
                    }
                }
            }
            .alert("Delete Ingredient", isPresented: $inventory.showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        if let item = inventoryVm.pendingItem {
                            await inventoryVm.deleteInventoryItem(id: item.id)
                            await recipesVm.inventoryUpdated()
                        }
                    }
                }
                Button("Cancel", role: .cancel) {
                    inventoryVm.pendingItem = nil
                }
            } message: {
                Text("Are you sure you want to delete \(inventoryVm.pendingItem?.name ?? "this ingredient")?")
            }
            .fullScreenCover(isPresented: $showSuggestedRecipes) {
                SuggestedRecipesList()
            }
            .navigationTitle("Inventory")
        }
    }
}

#Preview {
    InventoryView.preview
}
