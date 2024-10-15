import SwiftUI

@Observable
final class AddRecipeVM {
    var name = ""
    var description = ""
    var guide: [String] = ["", "", ""]
    var time = 3
    var isPublic = false
    var allergens: [Allergen] = []
    var ingredients: [SelectionIngredient] = []
    
    var error = false
    var showAllergens = false
    
    func addGuideStep() {
        guide.append("")
    }
    
    func validationName(value: String) -> String? {
        value.isEmpty ? "must not be empty" : nil
    }
    
    func validationDescription(value: String) -> String? {
        nil
    }
    
    func validationGuide(value: [String]) -> String? {
        let guide = value.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        guard guide.count >= 3 else {
            return "The guide must contain at least 3 steps"
        }
        for step in guide {
            if step.isEmpty {
                return "Each step must contain valid text"
            }
        }
        return nil
    }
    
    func validationTime(value: Int) -> String? {
        value < 3 ? "must not be less than 3 min" : nil
    }
    
    func validateIngredients(value: [SelectionIngredient]) -> String? {
        value.count < 3 ? "Recipes must have more than 2 ingredients" : nil
    }
    
//    func validateAllFields() -> Bool {
//        true
//    }
    
    func toggleAllergenSelection(value: Allergen) {
        if let index = allergens.firstIndex(of: value) {
            allergens.remove(at: index)
        } else {
            allergens.append(value)
        }
    }
    
    func isAllergenAdded(value: Allergen) -> Bool {
        return allergens.contains(value)
    }
    
    func addRecipe() async {
        
    }
    
    
}
