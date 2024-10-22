import SwiftUI

struct IngredientsSelectedList: View {
    @Binding var showIngredientsForm: Bool
    @Binding var ingredients: [SelectionIngredient]
    @Binding var isError: Bool
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
            }
            else {
                VStack(alignment: .leading) {
                    ForEach(ingredients, id: \.self) { ing in
                        HStack{
                            
                            Text(ing.name)
                            Spacer()
                            switch ing.unit {
                            case .units:
                                Text("\(ing.quantity, specifier: "%.0f") units")
                            case .volume:
                                Text("\(ing.quantity, specifier: "%.2f") L")
                            case .weight:
                                Text("\(ing.quantity, specifier: "%.2f") g")
                            }
                        }
                        .padding(.bottom, 5)
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
