import SwiftUI

struct IngredientsSelector: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
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
                        .overlay {
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
                        }
                        .padding(.horizontal)
                        .focused($focusedField, equals: .search)
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
                                        .focused($focusedField, equals: .ingredient(ingredient.id))
                                        .submitLabel(.next)
                                        .onTapGesture {
                                            focusedField = .ingredient(ingredient.id)
                                        }
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
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            focusedField = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down.fill")
                        }
                    }
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
                        Text("\(i.quantity, specifier: "%.0f") \(i.unit == .units && i.quantity == 1 ? "unit" : i.unit.rawValue)")
                    }
                }
                .presentationDetents([.large, .fraction(0.5)],
                                     selection: $detent)
                .presentationBackgroundInteraction(.enabled)
            }
        }
        .onTapGesture {
            if let _ = focusedField {
                focusedField = nil
            }
        }
    }
}

extension IngredientsSelector {
    enum Field: Hashable {
        case search
        case ingredient(UUID)
    }
}


#Preview {
    IngredientsSelector.preview
}

