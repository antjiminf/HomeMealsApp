import SwiftUI
import SwiftData

struct ShoppingListFormView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var shoppingListVm = ShoppingListGeneratorVM()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Date Selector") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            if shoppingListVm.hasDateError {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            
                            DatePicker("Start Date", selection: $shoppingListVm.startDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .onChange(of: shoppingListVm.startDate, initial: true) {
                                    shoppingListVm.generationToggled = false
                                    shoppingListVm.validateDates()
                                }
                        }
                        
                        if let errorMessage = shoppingListVm.dateErrorMessage {
                            Text(errorMessage)
                                .font(.caption2)
                                .foregroundStyle(.red)
                                .bold()
                                .padding(.horizontal, 10)
                                .opacity(shoppingListVm.hasDateError ? 1.0 : 0.0)
                                .accessibilityLabel(Text("Date error message."))
                                .accessibilityHint(Text("This is an error validation message for the field start date. Fix the error to continue."))
                        }
                    }
                    .padding(.top)
                    
                    DatePicker("End Date", selection: $shoppingListVm.endDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.bottom)
                        .onChange(of: shoppingListVm.endDate, initial: true) {
                            shoppingListVm.generationToggled = false
                            shoppingListVm.validateDates()
                        }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Display Groceries List")
                                .font(.headline)
                            Text("Based on inventory")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                shoppingListVm.isLoading = true
                            }
                            Task {
                                await shoppingListVm.generateShoppingList(in: modelContext)
                            }
                        } label: {
                            Image(systemName: "cart.fill")
                                .padding(8)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(shoppingListVm.isLoading)
                        .opacity(shoppingListVm.isLoading ? 0.5 : 1.0)
                        .animation(.easeInOut, value: shoppingListVm.isLoading)
                    }
                }
                
                if shoppingListVm.isLoading {
                    VStack(spacing: 15) {
                        ProgressView("Generating groceries list...")
                        Text("Please wait a moment...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                    
                } else if !shoppingListVm.shoppingList.isEmpty {
                    Section {
                        List {
                            ForEach(shoppingListVm.shoppingList.indices, id: \.self) { index in
                                let item = shoppingListVm.shoppingList[index]
                                HStack {
                                    
                                    Text(item.name)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    TextField("Quantity",
                                              value: $shoppingListVm.shoppingList[index].requiredQuantity,
                                              format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 80, alignment: .trailing)
                                    .multilineTextAlignment(.trailing)
                                    .textFieldStyle(.roundedBorder)
                                    
                                    Text(item.unit.rawValue)
                                        .frame(width: 40, alignment: .leading)
                                    
                                    Stepper(value: $shoppingListVm.shoppingList[index].requiredQuantity,
                                            in: item.unit == .units ? 1...Double.infinity : 0.1...Double.infinity,
                                            step: item.unit == .units ? 1 : 0.1) {
                                        EmptyView()
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                            .onDelete(perform: shoppingListVm.removeItem)
                        }
                    } header: {
                        HStack {
                            Text("Groceries List")
                            Image(systemName: "cart.fill")
                                .foregroundColor(.green)
                            Spacer()
                            Button {
                                shoppingListVm.loadSelectedIngredients()
                                shoppingListVm.showIngredientsSelector = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    
                } else if shoppingListVm.generationToggled {
                    ContentUnavailableView("No groceries required",
                                           systemImage: "cart.fill.badge.questionmark",
                                           description: Text("Please add meals to your schedule to generate a shopping list"))
                }
            }
            .fullScreenCover(isPresented: $shoppingListVm.showIngredientsSelector) {
                IngredientsSelector(selectorVM: IngredientSelectorVM(),
                                    selectedIngredients: $shoppingListVm.ingredientsInList,
                                    title: "Add Groceries")
                .onDisappear {
                    shoppingListVm.updateShoppingList()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await shoppingListVm.saveShoppingList(in: modelContext)
                        }
                        dismiss()
                    }
                    .disabled(shoppingListVm.hasDateError)
                }
                
            }
            .navigationTitle("Create Groceries List")
        }
    }
}

#Preview {
    ShoppingListFormView.preview
}
