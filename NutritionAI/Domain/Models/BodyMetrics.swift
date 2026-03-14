import Foundation

enum BiologicalSex: String, Codable, CaseIterable, Identifiable {
    case male, female
    var id: String { rawValue }
}

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary
    case lightlyActive
    case moderatelyActive
    case veryActive
    case extraActive

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sedentary: "Sedentary"
        case .lightlyActive: "Lightly Active"
        case .moderatelyActive: "Moderately Active"
        case .veryActive: "Very Active"
        case .extraActive: "Extra Active"
        }
    }

    var multiplier: Double {
        switch self {
        case .sedentary: 1.2
        case .lightlyActive: 1.375
        case .moderatelyActive: 1.55
        case .veryActive: 1.725
        case .extraActive: 1.9
        }
    }
}

enum WeightGoal: String, Codable, CaseIterable, Identifiable {
    case lose1kg
    case lose05kg
    case maintain
    case gain05kg

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lose1kg: "Lose 1 kg/week"
        case .lose05kg: "Lose 0.5 kg/week"
        case .maintain: "Maintain"
        case .gain05kg: "Gain 0.5 kg/week"
        }
    }

    var calorieAdjustment: Double {
        switch self {
        case .lose1kg: -1000
        case .lose05kg: -500
        case .maintain: 0
        case .gain05kg: 500
        }
    }
}

/// User body metrics for calorie goal calculation.
struct BodyMetrics: Codable, Equatable {
    var weightKg: Double
    var heightCm: Double
    var age: Int
    var sex: BiologicalSex
    var activityLevel: ActivityLevel
    var weightGoal: WeightGoal

    /// Basal Metabolic Rate using Mifflin-St Jeor equation.
    var bmr: Double {
        let base = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age))
        return sex == .male ? base + 5 : base - 161
    }

    /// Total Daily Energy Expenditure.
    var tdee: Double {
        bmr * activityLevel.multiplier
    }

    /// Daily calorie goal adjusted for weight goal.
    var dailyCalorieGoal: Double {
        max(1200, tdee + weightGoal.calorieAdjustment)
    }

    /// BMI value.
    var bmi: Double {
        let heightM = heightCm / 100
        guard heightM > 0 else { return 0 }
        return weightKg / (heightM * heightM)
    }

    static let placeholder = BodyMetrics(
        weightKg: 70,
        heightCm: 170,
        age: 30,
        sex: .male,
        activityLevel: .moderatelyActive,
        weightGoal: .maintain
    )
}
