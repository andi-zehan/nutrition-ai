import Foundation

/// Aggregated nutrition data for a date range window.
struct TrendSnapshot: Equatable {
    let range: TrendRange
    let totalNutrition: NutritionTotals
    let activeDays: Int
    let mealCount: Int

    var averageDailyCalories: Double {
        let days = max(activeDays, 1)
        return totalNutrition.calories / Double(days)
    }

    var proteinPercent: Double {
        macroPercent(totalNutrition.proteinGrams * 4)
    }

    var carbsPercent: Double {
        macroPercent(totalNutrition.carbsGrams * 4)
    }

    var fatPercent: Double {
        macroPercent(totalNutrition.fatGrams * 9)
    }

    private func macroPercent(_ macroCalories: Double) -> Double {
        let total = (totalNutrition.proteinGrams * 4)
            + (totalNutrition.carbsGrams * 4)
            + (totalNutrition.fatGrams * 9)
        guard total > 0 else { return 0 }
        return (macroCalories / total) * 100
    }

    static let empty = TrendSnapshot(
        range: .today,
        totalNutrition: .zero,
        activeDays: 0,
        mealCount: 0
    )
}

enum TrendRange: String, CaseIterable, Identifiable {
    case today = "Today"
    case last7Days = "7 Days"
    case last30Days = "30 Days"

    var id: String { rawValue }

    var dayCount: Int {
        switch self {
        case .today: 1
        case .last7Days: 7
        case .last30Days: 30
        }
    }
}
