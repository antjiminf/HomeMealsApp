import SwiftUI

struct AllergensSelector: View {
    var allergens: [Allergen]
    @Binding var showAllergens: Bool
    let toggleAllergen: (Allergen) -> Void
    let isAllergenSelected: (Allergen) -> Bool
    
    var body: some View {
        Section("Allergens") {
            //TODO: ACCESIBILIDAD
            HStack {
                if allergens.isEmpty {
                    Text("Allergens: None")
                        .bold()
                } else {
                    Text("Allergens: \(allergens.map{$0.rawValue}.joined(separator: ", "))")
                        .bold()
                }
                Spacer()
                Button {
                    showAllergens.toggle()
                } label: {
                    HStack {
                        Text("Allergens")
                        Image(systemName: showAllergens ? "arrow.up" : "arrow.down")
                    }
                }
            }
            if showAllergens {
                VStack {
                    ForEach(Allergen.allCases, id: \.self) { allergen in
                        HStack {
                            Image(allergen.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                            Text(allergen.rawValue)
                            Spacer()
                            Button(action: {
                                toggleAllergen(allergen)
                            }) {
                                Image(systemName: isAllergenSelected(allergen) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor( isAllergenSelected(allergen) ? .blue : .gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}


//#Preview {
//    
//    var allergens: [Allergen] = []
//    
//    func toggleAllergen(_ allergen: Allergen) {
//        if let index = allergens.firstIndex(of: allergen) {
//            allergens.remove(at: index)
//        } else {
//            allergens.append(allergen)
//        }
//    }
//    
//    func isAllergenSelected(_ allergen: Allergen) -> Bool {
//        allergens.contains(allergen)
//    }
//    
//    AllergensSelector(
//        allergens: [],
//        showAllergens: .constant(true),
//        toggleAllergen: toggleAllergen,
//        isAllergenSelected: isAllergenSelected)
//    )
//}
