import Foundation

/// Contract for nutrition data lookup from a food database.
protocol NutritionLookupService: Sendable {
    /// Look up nutrition per 100g for a given ingredient name.
    func lookup(ingredientName: String) async throws -> NutritionPer100g?
    /// Search for ingredient names matching a query.
    func search(query: String) async throws -> [FoodSearchResult]
}

/// Nutrition values per 100 grams of a food item.
struct NutritionPer100g: Codable, Equatable {
    let foodName: String
    let calories: Double
    let proteinGrams: Double
    let carbsGrams: Double
    let fatGrams: Double
}

/// A search result from the food database.
struct FoodSearchResult: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let dataType: String?
}

enum NutritionLookupError: LocalizedError {
    case notFound(String)
    case networkError(Error)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .notFound(let name): "No nutrition data found for '\(name)'."
        case .networkError(let error): "Network error: \(error.localizedDescription)"
        case .apiError(let message): "API error: \(message)"
        }
    }
}
