import Foundation

/// Calculated calories and macros for a meal.
struct NutritionTotals: Codable, Equatable {
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double

    static let zero = NutritionTotals(calories: 0, proteinGrams: 0, carbsGrams: 0, fatGrams: 0)

    static func + (lhs: NutritionTotals, rhs: NutritionTotals) -> NutritionTotals {
        NutritionTotals(
            calories: lhs.calories + rhs.calories,
            proteinGrams: lhs.proteinGrams + rhs.proteinGrams,
            carbsGrams: lhs.carbsGrams + rhs.carbsGrams,
            fatGrams: lhs.fatGrams + rhs.fatGrams
        )
    }
}
