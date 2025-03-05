import SwiftUI

struct CustomTextField: View {
    let label: String
    @Binding var value: String
    @Binding var isError: Bool
    var hint: String
    let validation: (String) -> String?
    var initial = true
    var lines = 1
    
    @State private var error = false
    @State private var errorMsg = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.capitalized)
                .bold()
                .padding(.bottom, 5)
                .accessibilityHidden(true)
            HStack(alignment: .top) {
                if lines > 1 {
                    TextField("Enter the \(label.lowercased())", text: $value, axis: .vertical)
                        .accessibilityHint(Text(hint))
                        .accessibilityLabel(Text(label))
                        .lineLimit(lines, reservesSpace: true)
                } else {
                    TextField("Enter the \(label.lowercased())", text: $value)
                        .accessibilityHint(Text(hint))
                        .accessibilityLabel(Text(label))
                }
                if !value.isEmpty {
                    Button {
                        value = ""
                    } label: {
                        Image(systemName: "xmark")
                            .symbolVariant(.fill)
                            .symbolVariant(.circle)
                    }
                    .buttonStyle(.plain)
                    .opacity(/*error ? 0.0 : */0.5)
                    .accessibilityLabel(Text("\(label) delete value."))
                    .accessibilityHint(Text("Tap this button to delete the value of the field."))
                }
            }
            .padding(10)
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
    }
}
