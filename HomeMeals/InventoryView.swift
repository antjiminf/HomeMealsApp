import SwiftUI

struct InventoryView: View {
    @Environment(InventoryVM.self) var inventoryVm
    @State var detent: PresentationDetent = .fraction(0.25)
    @State var ingredients: [SelectionIngredient] = []
    @State var showAddIngredients = false
    @State var showConsumeIngredients = false
    
    var body: some View {
        @Bindable var inventory = inventoryVm
        
        NavigationStack {
            VStack {
                TextField("Search ingredients...", text: $inventory.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.horizontal, .top])
                
                Group {
                    if !inventoryVm.filteredInventory.isEmpty {
                        List {
                            ForEach(inventoryVm.filteredInventory.sorted(by: {
                                $0.name < $1.name
                            })) { item in
                                HStack {
                                    Text(item.name)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    switch item.unit {
                                    case .units:
                                        Text("\(item.quantity, specifier: "%.0f") units")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    case .weight:
                                        Text("\(item.quantity, specifier: "%.1f") g")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    case .volume:
                                        Text("\(item.quantity, specifier: "%.1f") L")
                                            .font(.headline)
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
                        .refreshable {
                            await inventoryVm.loadInventory()
                        }
                    } else {
                        ContentUnavailableView(
                            "No coincidences",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text("No ingredients found containing \"\(inventoryVm.searchText)\""))
                    }
                }
            }
            .sheet(isPresented: $inventory.showingEditModal) {
                if let item = inventoryVm.editingItem {
                    EditQuantityView(inventoryItemVm: InventoryItemVm(inventoryItem: item))
                        .environment(inventoryVm)
                        .presentationDetents([.fraction(0.25), .medium],
                                             selection: $detent)
                        .presentationBackgroundInteraction(.enabled)
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
                        }
                    }
                }
            }
            .alert("Delete Ingredient", isPresented: $inventory.showingDeleteConfirmation, actions: {
                Button("Delete", role: .destructive) {
                    Task {
                        if let item = inventoryVm.pendingItem {
                            await inventoryVm.deleteInventoryItem(id: item.id)
                            inventoryVm.pendingItem = nil
                        }
                    }
                }
                Button("Cancel", role: .cancel) {
                    inventoryVm.pendingItem = nil
                }
            }, message: {
                Text("Are you sure you want to delete \(inventoryVm.pendingItem?.name ?? "this ingredient")?")
            })
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        showAddIngredients = true
//                    } label: {
//                        Label("Add", systemImage: "plus.circle.fill")
//                            .labelStyle(IconOnlyLabelStyle())
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        showConsumeIngredients = true
//                    } label: {
//                        Label("Consume", systemImage: "minus.circle.fill")
//                            .labelStyle(IconOnlyLabelStyle())
//                    }
//                }
//            }
            .overlay(alignment: .bottomTrailing) {
                VStack {
                    Button {
                        showAddIngredients = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .shadow(radius: 5)
                    }
                    .accessibilityLabel("Add Ingredients")
                    .padding(.bottom)
                    
                    Button {
                        showConsumeIngredients = true
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                            .tint(.red)
                            .shadow(radius: 5)
                    }
                    .accessibilityLabel("Consume Ingredients")
                }
                .padding()
            }
            .navigationTitle("Inventory")
        }
    }
}


#Preview {
    InventoryView.preview
}
