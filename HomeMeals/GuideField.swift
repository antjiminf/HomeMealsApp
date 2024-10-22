import SwiftUI

struct GuideField: View {
    
    @Binding var guide: [String]
    @Binding var isError: Bool
    let validation: ([String]) -> String?
    @State var initial = true
    let addGuideStep: () -> Void
    let removeLastStep: () -> Void
    
    @State private var error = false
    @State private var errorMsg = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Guide")
                .bold()
            
            VStack {
                ForEach(0..<guide.count, id: \.self) { index in
                    TextField("Step \(index + 1)",
                              text: Binding(
                                get: { guide[index] },
                                set: { guide[index] = $0 }
                              ),
                              axis: .vertical)
                    .lineLimit(2, reservesSpace: true)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemBackground))
                    }
                    .onChange(of: guide) {
                        if !initial {
                            if let message = validation(guide) {
                                error = true
                                errorMsg = message
                            } else {
                                error = false
                                errorMsg = ""
                            }
                            isError = error
                        } else {
                            initial.toggle()
                        }
                    }
                    
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2.0)
                    .fill(.red)
                    .padding(2)
                    .opacity(error ? 1.0 : 0.0)
            }
            
            Text("\(errorMsg).")
                .font(.caption2)
                .foregroundStyle(.red)
                .bold()
                .padding(.horizontal, 10)
                .opacity(error ? 1.0 : 0.0)
                .accessibilityLabel(Text("Ingredients error message."))
                .accessibilityHint(Text("This is an error validation message for the field ingredients. Fix the error to continue."))
            
            HStack {
                Button {
                    addGuideStep()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add step")
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .contentShape(Rectangle())
                .padding(.top, 5)
                
                Spacer()
                
                if guide.count > 3 {
                    Button {
                        removeLastStep()
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Remove last")
                        }
                    }
                    .foregroundStyle(.gray)
                    .buttonStyle(BorderlessButtonStyle())
                    .contentShape(Rectangle())
                    .padding(.top, 5)
                }
            }
        }
    }
}
