import SwiftUI

@Observable
final class FilterRecipesVM {
    
    var name: String = ""
    var minTime: Double = 3 {
        didSet {
            if minTime > 240 {
                minTime = 240
                maxTime = 240
            } else if minTime < 3 {
                minTime = 3
            } else if minTime == 240 || minTime > maxTime {
                maxTime = 240
            }
        }
    }
    var maxTime: Double = 240 {
        didSet {
            if maxTime > 240 {
                maxTime = 240
            } else if maxTime < 3 {
                maxTime = 3
                minTime = 3
            } else if maxTime == 3 || maxTime < minTime {
                minTime = 3
            }
        }
    }
    var allergens: Set<Allergen> = []    
    
    func applyFilters() -> (String?, Int?, Int?, [Allergen]?) {
        return (name.isEmpty ? nil : name,
                minTime == 3 ? nil : Int(minTime),
                maxTime == 240 ? nil : Int(maxTime),
                allergens.isEmpty ? nil : Array(allergens))
    }
    
    func toggleAllergen(allergen: Allergen) {
        if allergens.contains(allergen) {
            allergens.remove(allergen)
        } else {
            allergens.insert(allergen)
        }
    }
    
    func allergenFree() {
        allergens = allergens.union(Allergen.allCases)
    }
    
    func cleanAllergens() {
        allergens.removeAll()
    }
    
    func checkForChanges() -> Bool {
        !name.isEmpty ||
        minTime != 3 ||
        maxTime != 240 ||
        !allergens.isEmpty
    }
}
