import Foundation

enum FoodCategory: String, Identifiable, Codable, CaseIterable, Comparable {
    
    static func < (lhs: FoodCategory, rhs: FoodCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case bakeryPastry = "bakery-pastry"
    case beverage
    case cerealsGrains = "cereals-grains"
    case dairy
    case fish
    case fruit
    case herbsSpices = "herbs-spices"
    case legumes
    case meat
    case nutsSeeds = "nuts-seeds"
    case oilFat = "oil-fat"
    case seafood
    case sweetDessert = "sweet-dessert"
    case vegetable
    
    var id: Self { self }
}

enum Unit: String, Codable, CaseIterable, Identifiable {
    case volume = "L"
    case units = "units"
    case weight = "g"
    
    var id: Self { self }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue.lowercased() {
        case "volume":
            self = .volume
        case "units":
            self = .units
        case "weight":
            self = .weight
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown unit: \(rawValue)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .volume:
            try container.encode("volume")
        case .units:
            try container.encode("units")
        case .weight:
            try container.encode("weight")
        }
    }
}

enum Allergen: String, Identifiable, Codable, CaseIterable {
    case celery
    case crustaceans
    case dairy
    case egg
    case fish
    case gluten
    case lupin
    case molluscs
    case mustard
    case nuts
    case peanut
    case sesame
    case soy
    case sulphites
    
    var id: Self { self }
}
