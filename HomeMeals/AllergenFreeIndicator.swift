import SwiftUI

struct AllergenFreeIndicator: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
            Text("Allergen Free")
                .font(.footnote)
        }
        .foregroundColor(.green)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color.green.opacity(0.2)))
    }
}

#Preview {
    AllergenFreeIndicator()
}
