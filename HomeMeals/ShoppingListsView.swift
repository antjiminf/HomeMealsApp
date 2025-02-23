import SwiftUI
import SwiftData

struct ShoppingListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GroceriesList.createdAt, order: .reverse) var groceriesLists: [GroceriesList]
    @State private var showForm = false
    
    var body: some View {
        NavigationStack {
            List {
                if groceriesLists.isEmpty {
                    ContentUnavailableView("No Shopping Lists",
                                           systemImage: "cart.badge.plus",
                                           description: Text("Tap + to create your first shopping list."))
                } else {
                    ForEach(groceriesLists, id: \.self) { list in
                        NavigationLink {
                            ShoppingListDetailView(list)
                            //TODO: VER PORQUE TENGO QUE INYECTARLO PARA QUE NO PETE LA PREVIEW
//                                .environment(InventoryVM())
//                                .environment(RecipesVM())
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Groceries from \(list.startDate.dateFormatter) to \(list.endDate.dateFormatter)")
                                    .font(.headline)
                                
                                Text("\(list.items.count) items")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .opacity(list.isCompleted ? 0.5 : 1)
                    }
                    .onDelete(perform: deleteList)
                }
            }
            .navigationTitle("Shopping Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .fullScreenCover(isPresented: $showForm) {
                ShoppingListFormView()
            }
        }
    }
    
    private func deleteList(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(groceriesLists[index])
        }
    }
}

#Preview {
    ShoppingListsView.preview
}
