import SwiftUI

@Observable
final class AddRecipeVM {
    
    init(recipe: Recipe? = nil) {
        if let recipe = recipe {
            id = recipe.id
            name = recipe.name
            description = recipe.description
            guide = recipe.guide
            time = recipe.time
            isPublic = true //TODO: RECIBIR PARAMETRO ISPUBLIC PARA FUTUROS PROBLEMAS
            //Cuando quiero hacer update no se si la receta es true o false
            allergens = recipe.allergens
            ingredients = recipe.ingredients.map{ $0.toSelectionIngredient() }
        }
    }
    
    var id: UUID? = nil
    
    var name = ""
    var description = ""
    var guide: [String] = ["", "", ""]
    var time = 3
    var isPublic = false
    var allergens: [Allergen] = []
    var ingredients: [SelectionIngredient] = []
    
    var error = false
    var showAlert = false
    var showAllergens = false
    
    func addGuideStep() {
        guide.append("")
    }
    
    func removeLastStep() {
        guide.removeLast()
    }
    
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
    
    //TODO: BORRAR ING SELECCIONADOS
    // PROBAR METER EL FOREACH DE LOS ING SOLAMENTE EN UN SECTION PARA HACER ONDELETE COMO EN SCORESSWIFTUI
//    func removeIngredient(index: Int) {
//        ingredients.remove(at: index)
//    }
//    
//    private func deleteIngredients(at offsets: IndexSet) {
//        ingredients.remove(atOffsets: offsets)
//    }
//    func deleteIngredient(at offsets: IndexSet) {
//            ingredients.remove(atOffsets: offsets)
//        }
    
    func validationName(value: String) -> String? {
        value.isEmpty ? "must not be empty" : nil
    }
    
    func validationDescription(value: String) -> String? {
        nil
    }
    
    func validationGuide(value: [String]) -> String? {
        let guide = value.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter{!$0.isEmpty}
        
        guard guide.count >= 3 else {
            return "The guide must contain at least 3 written steps"
        }
        return nil
    }
    
    func validationTime(value: Int) -> String? {
        value < 3 ? "must not be less than 3 min" : nil
    }
    
    func validateIngredients(value: [SelectionIngredient]) -> String? {
        value.filter{$0.quantity > 0.1}.count < 3 ? "Recipes must have at least 3 ingredients" : nil
    }
    
    func validateAllFields() -> Bool {
        
        if validationName(value: name) != nil {
            error = true
            return false
        }
        
        if validationGuide(value: guide) != nil {
            error = true
            return false
        }
        
        if validationTime(value: time) != nil {
            error = true
            return false
        }
        
        if validateIngredients(value: ingredients) != nil {
            error = true
            return false
        }
        
        return true
    }
    
    func createRecipeDto() -> CreateRecipeDTO? {
        guard validateAllFields() else {
            return nil
        }
        
        return CreateRecipeDTO(name: name,
                               description: description,
                               time: time,
                               isPublic: isPublic,
                               ingredients: ingredients.map{$0.toCreateRecipeIngredient()},
                               guide: guide.filter{!$0.isEmpty},
                               allergens: allergens)
    }
    
//    func 
    
}
