import SwiftUI

struct MinutesStepper: View {
    let label: String
    @Binding var value: Int
    var initial = true
    var hint: String
    @Binding var isError: Bool
    let validation: (Int) -> String?
    
    @State private var error = false
    @State private var errorMsg = ""
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Time")
                .bold()
            Stepper(value: $value, in: 3...240, step: 1) {
                
                HStack {
                    Text("In minutes:")
                        .bold()
                    TextField("3", value: $value, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }
            }
            .padding()
            .onChange(of: value, initial: initial) {
                if let message = validation(value) {
                    error = true
                    errorMsg = message
                } else {
                    error = false
                    errorMsg = ""
                }
                isError = error
            }
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
            Text("\(label.capitalized) \(errorMsg).")
                .font(.caption2)
                .foregroundStyle(.red)
                .bold()
                .padding(.horizontal, 10)
                .opacity(error ? 1.0 : 0.0)
                .accessibilityLabel(Text("\(label) error message."))
                .accessibilityHint(Text("This is an error validation message for the field \(label). Fix the error to continue."))
        }
    }
}
