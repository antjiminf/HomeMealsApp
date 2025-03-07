import SwiftUI
import SwiftData

struct ShoppingListDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @Environment(\.modelContext) var modelContext
    @Environment(InventoryVM.self) var inventoryVm
    @Environment(RecipesVM.self) var recipesVm
    @Bindable var list: GroceriesList
    @State var detailsVm: ShoppingListDetailVM
    
    init(_ list: GroceriesList) {
        self.list = list
        self.detailsVm = .init(list)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(list.startDate.dateFormatter+" - "+list.endDate.dateFormatter)")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                List {
                    
                    if !detailsVm.missingItems.isEmpty {
                        Section(header: Text("Remaining Items")) {
                            ForEach(detailsVm.missingItems) { item in
                                GroceryRow(item: item, toggleObtained: detailsVm.toggleObtained)
                                    .focused($isFocused)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            detailsVm.pendingItem = item
                                            detailsVm.showDeleteItemAlert = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    
                    if !detailsVm.obtainedItems.isEmpty {
                        Section {
                            ForEach(detailsVm.obtainedItems) { item in
                                GroceryRow(item: item, toggleObtained: detailsVm.toggleObtained)
                                    .opacity(0.5)
                            }
                        } header: {
                            HStack {
                                Text("Obtained items")
                                Spacer()
                                if !list.isCompleted {
                                    Button {
                                        detailsVm.markAllAsMissing()
                                    } label: {
                                        Image(systemName: "arrow.uturn.backward.circle.fill")
                                        Text("Undo")
                                            .textCase(nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if list.isCompleted {
                        HStack {
                            Text("Completed")
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundStyle(.green)
                        .opacity(0.8)
                    } else {
                        Button("Add to inventory") {
                            detailsVm.showConfirmationAlert = true
                        }
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            isFocused = false
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down.fill")
                        }
                    }
                }
            }
            .alert("Confirm save", isPresented: $detailsVm.showConfirmationAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .destructive) {
                    Task {
                        await inventoryVm.addGroceries(groceries: detailsVm.getSelectionIngredients())
                        await recipesVm.inventoryUpdated()
                        detailsVm.completeList()
                        dismiss()
                    }
                }
            } message: {
                Text("This action will add the items to your inventory and mark the shopping list as completed. Are you sure?")
            }
            .alert("Delete Grocery?", isPresented: $detailsVm.showDeleteItemAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .destructive) {
                    if let item = detailsVm.pendingItem {
                        detailsVm.deleteItem(item)
                    }
                }
            } message: {
                Text("This action will remove \(detailsVm.pendingItem?.name ?? "") from the list. Are you sure?")
            }
        }
        .onTapGesture {
            if isFocused {
                isFocused = false
            }
        }
    }
}

#Preview {
    ShoppingListDetailView.preview
}
