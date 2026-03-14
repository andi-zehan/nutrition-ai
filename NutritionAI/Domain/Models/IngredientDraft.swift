import Foundation

/// Units supported for ingredient quantities in MVP.
enum IngredientUnit: String, Codable, CaseIterable, Identifiable {
    case grams, ml, servings, cups, tbsp, tsp, slices, pieces

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grams: "g"
        case .ml: "ml"
        case .servings: "serving(s)"
        case .cups: "cup(s)"
        case .tbsp: "tbsp"
        case .tsp: "tsp"
        case .slices: "slice(s)"
        case .pieces: "piece(s)"
        }
    }
}

/// A single editable ingredient row used during the review step.
struct IngredientDraft: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: IngredientUnit

    init(id: UUID = UUID(), name: String, quantity: Double, unit: IngredientUnit) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}
