import SwiftUI

struct IngredientsSelectedList: View {
    @FocusState.Binding var focusedField: RecipeFormView.Field?
    @Binding var showIngredientsForm: Bool
    @Binding var ingredients: [SelectionIngredient]
    @Binding var isError: Bool
//    let removeIngredient: (Int) -> Void
    let validation: ([SelectionIngredient]) -> String?
    var initial = true
    
    @State private var error = false
    @State private var errorMsg = ""
    
    var body: some View {
        VStack {
            HStack{
                Text("Ingredients")
                    .bold()
                Spacer()
                Button {
                    showIngredientsForm.toggle()
                } label: {
                    Text("Edit")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.bottom)
            if ingredients.isEmpty {
                HStack {
                    Text("No ingredients selected")
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.secondarySystemBackground))
                }
                .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading) {
                    List {
                        ForEach(ingredients.indices, id: \.self) { index in
                            
                            HStack  {
//                                Button {
//                                    removeIngredient(index)
//                                } label: {
//                                    Image(systemName: "minus.circle.fill")
//                                        .foregroundStyle(.red)
//                                }
                                
                                Text(ingredients[index].name)
                                Spacer()
                                
                                TextField(
                                    "Quantity",
                                    value: $ingredients[index].quantity,
                                    formatter: NumberFormatter()
                                )
                                .foregroundStyle(ingredients[index].quantity == 0 ? .gray : .black)
                                .padding(5)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.systemBackground))
                                }
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                
                                Text(ingredients[index].unit.rawValue)
                                    .frame(width: 40, alignment: .leading)
                            }
                            .focused($focusedField, equals: .ingredientQuantity(index))
                            .padding(.bottom, 5)
                            Divider()
                        }
//                        .onDelete(perform: deleteIngredients)
                    }
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2.0)
                        .fill(.red)
                        .padding(2)
                        .opacity(error ? 1.0 : 0.0)
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.secondarySystemBackground))
                }
                .onChange(of: ingredients, initial: initial) {
                    if let message = validation(ingredients) {
                        error = true
                        errorMsg = message
                    } else {
                        error = false
                        errorMsg = ""
                    }
                    isError = error
                }
                
                Text("\(errorMsg).")
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .bold()
                    .padding(.horizontal, 10)
                    .opacity(error ? 1.0 : 0.0)
                    .accessibilityLabel(Text("Ingredients error message."))
                    .accessibilityHint(Text("This is an error validation message for the field ingredients. Fix the error to continue."))
            }
        }
        .padding(.bottom)
        
    }
}
