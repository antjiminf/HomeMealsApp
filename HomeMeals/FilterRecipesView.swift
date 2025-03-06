import SwiftUI

struct FilterRecipesView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @Environment(RecipesVM.self) var recipesVm
    
    @State var filterVm: FilterRecipesVM
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Recipe Name")) {
                    HStack {
                        TextField("Enter recipe name", text: $filterVm.name)
                            .padding(.vertical, 5)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                        if !filterVm.name.isEmpty {
                            Button {
                                filterVm.name = ""
                            } label: {
                                Image(systemName: "xmark")
                                    .symbolVariant(.fill)
                                    .symbolVariant(.circle)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text("Deletes name value."))
                            .accessibilityHint(Text("Tap this button to delete the value of the field."))
                        }
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemBackground))
                    }
                }
                
                Section(header: Text("Preparation Time")) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Min time:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Min time", value: $filterVm.minTime, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                                .focused($focusedField, equals: .minTime)
                                .submitLabel(.next)
                        }
                        Slider(value: $filterVm.minTime,
                               in: 3...240,
                               step: 1)
                        Spacer()
                        HStack {
                            Text("Max time:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Max time", value: $filterVm.maxTime, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                                .focused($focusedField, equals: .maxTime)
                                .submitLabel(.next)
                        }
                        Slider(value: $filterVm.maxTime,
                               in: 3...240,
                               step: 1)
                    }
                    .padding()
                }
                
                Section {
                    ForEach(Allergen.allCases, id: \.self) { allergen in
                        HStack {
                            Image(allergen.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text(allergen.rawValue.capitalized)
                            Spacer()
                            if filterVm.allergens.contains(allergen) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            filterVm.toggleAllergen(allergen: allergen)
                        }
                    }
                } header: {
                    HStack {
                        Text("Exclude Allergens")
                        Spacer()
                        AllergenFreeIndicator()
                            .onTapGesture {
                                filterVm.allergenFree()
                            }
                        if !filterVm.allergens.isEmpty {
                            Button {
                                filterVm.cleanAllergens()
                            } label: {
                                Image(systemName: "xmark")
                                    .symbolVariant(.fill)
                                    .symbolVariant(.circle)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text("Deletes name value."))
                            .accessibilityHint(Text("Tap this button to clean allergens selection."))
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        Task {
                            await recipesVm.filterRecipes(filters: filterVm.applyFilters())
                            dismiss()
                        }
                    }
                    .disabled(!filterVm.checkForChanges())
                }
                ToolbarItemGroup(placement: .keyboard) {
                    
                    Button {
                        focusedField?.previous()
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    Button {
                        focusedField?.next()
                    } label: {
                        Image(systemName: "chevron.down")
                        
                    }
                    Spacer()
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down.fill")
                    }
                    
                }
            }
            .onTapGesture {
                if let _ = focusedField {
                    focusedField = nil
                }
            }
        }
    }
}

extension FilterRecipesView {
    enum Field: Hashable {
        case name, minTime, maxTime
        
        mutating func next() {
            switch self {
            case .name:
                self = .minTime
            case .minTime:
                self = .maxTime
            case .maxTime:
                self = .name
            }
        }
        
        mutating func previous() {
            switch self {
            case .name:
                self = .maxTime
            case .minTime:
                self = .name
            case .maxTime:
                self = .minTime
            }
        }
    }
}

#Preview {
    FilterRecipesView.preview
}
