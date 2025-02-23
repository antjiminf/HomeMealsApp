import SwiftUI

struct IngredientsSelector: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(IngredientsVM.self) var ingredientsVM
    @State var selectorVM: IngredientSelectorVM
    @Binding var selectedIngredients: [SelectionIngredient]
    @State var detent: PresentationDetent = .fraction(0.5)
    let title: String

    var body: some View {
        @Bindable var ingredientsBindable = ingredientsVM

        NavigationStack {
            VStack {
                HStack {
                    TextField("Search ingredients...", text: $ingredientsBindable.searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            HStack {
                                Spacer()
                                if !ingredientsVM.searchText.isEmpty {
                                    Button { 
                                        ingredientsBindable.searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.trailing, 8)
                                }
                            }
                        )
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)

                Form {
                    Group {
                        if !ingredientsVM.filteredIngredients.isEmpty {
                            ForEach(ingredientsVM.ingredientsByCategory.keys.sorted(), id: \.self) { category in
                                Section {
                                    ForEach(ingredientsVM.ingredientsByCategory[category]?.sorted { $0.name < $1.name } ?? [], id: \.self) { ingredient in
                                        IngredientQuantity(
                                            ingredientName: ingredient.name,
                                            quantity: Binding(
                                                get: { selectorVM.quantityForIngredient(ingredient) },
                                                set: { newQuantity in
                                                    selectorVM.updateIngredientSelection(ingredient: ingredient, quantity: newQuantity)
                                                }
                                            ),
                                            unit: ingredient.unit)
                                    }
                                } header: {
                                    HStack {
                                        Image(systemName: "leaf.circle")
                                        Text(category.rawValue.capitalized)
                                            .font(.headline)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        } else {
                            Section {
                                ContentUnavailableView(
                                    "No coincidences",
                                    systemImage: "exclamationmark.magnifyingglass",
                                    description: Text("No ingredients found containing \"\(ingredientsVM.searchText)\"")
                                )
                                .padding(.vertical, 20)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        selectedIngredients = selectorVM.saveIngredients()
                        ingredientsBindable.searchText = ""
                        dismiss()
                    }
                    .accessibilityHint(Text("This button will confirm any change done"))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        ingredientsBindable.searchText = ""
                        dismiss()
                    }
                    .accessibilityHint(Text("Cancels the ingredients selection"))
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Show Selected") {
                        selectorVM.showSelectedIngredients.toggle()
                    }
                    .bold()
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .accessibilityHint(Text("Shows the list of ingredients selected"))
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectorVM.loadInitialSelectedIngredients(selectedIngredients)
            }
            .sheet(isPresented: $selectorVM.showSelectedIngredients) {
                List(selectorVM.sortedIngredients) { i in
                    HStack {
                        Text(i.name)
                        Spacer()
                        switch i.unit {
                            case .units:
                            Text("\(i.quantity, specifier: "%.0f") units")
                            case .volume:
                                Text("\(i.quantity, specifier: "%.1f") L")
                            case .weight:
                                Text("\(i.quantity, specifier: "%.1f") g")
                        }
                    }
                }
                .presentationDetents([.large, .fraction(0.5)],
                                     selection: $detent)
                .presentationBackgroundInteraction(.enabled)
            }
        }
    }
}


#Preview {
    IngredientsSelector.preview
}

