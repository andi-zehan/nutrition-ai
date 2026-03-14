import Foundation

/// Manages the ingredient review/edit state before nutrition calculation.
@MainActor
final class IngredientReviewViewModel: ObservableObject {
    @Published var ingredients: [IngredientDraft]
    @Published var isCalculating = false
    @Published var errorMessage: String?
    @Published var calculationResult: CalculationResult?
    @Published var skippedIngredients: [String] = []

    let draft: MealDraft

    init(draft: MealDraft) {
        self.draft = draft
        self.ingredients = draft.ingredients
    }

    func addIngredient(_ ingredient: IngredientDraft) {
        ingredients.append(ingredient)
    }

    func removeIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }

    func removeIngredient(id: UUID) {
        ingredients.removeAll { $0.id == id }
    }

    var canCalculate: Bool {
        !ingredients.isEmpty && ingredients.allSatisfy {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.quantity > 0
        }
    }

    func calculate(using service: sending NutritionLookupService) async {
        isCalculating = true
        errorMessage = nil
        skippedIngredients = []

        var totals = NutritionTotals.zero
        var skipped: [String] = []

        for ingredient in ingredients {
            do {
                if let nutrition = try await service.lookup(ingredientName: ingredient.name) {
                    let factor = conversionFactor(quantity: ingredient.quantity, unit: ingredient.unit)
                    totals = totals + NutritionTotals(
                        calories: nutrition.calories * factor,
                        proteinGrams: nutrition.proteinGrams * factor,
                        carbsGrams: nutrition.carbsGrams * factor,
                        fatGrams: nutrition.fatGrams * factor
                    )
                } else {
                    skipped.append(ingredient.name)
                }
            } catch {
                skipped.append(ingredient.name)
            }
        }

        skippedIngredients = skipped
        calculationResult = CalculationResult(
            nutrition: totals,
            ingredients: ingredients,
            draft: draft
        )
        isCalculating = false
    }

    /// Convert quantity+unit to a multiplier of "per 100g" nutrition values.
    private func conversionFactor(quantity: Double, unit: IngredientUnit) -> Double {
        let grams: Double
        switch unit {
        case .grams: grams = quantity
        case .ml: grams = quantity // approximate 1ml ≈ 1g for most foods
        case .cups: grams = quantity * 240
        case .tbsp: grams = quantity * 15
        case .tsp: grams = quantity * 5
        case .servings: grams = quantity * 100 // assume 100g per serving as default
        case .slices: grams = quantity * 30 // approximate slice weight
        case .pieces: grams = quantity * 50 // approximate piece weight
        }
        return grams / 100.0
    }
}

struct CalculationResult {
    let nutrition: NutritionTotals
    let ingredients: [IngredientDraft]
    let draft: MealDraft
}
