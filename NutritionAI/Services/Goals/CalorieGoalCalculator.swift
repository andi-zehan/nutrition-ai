import Foundation

/// Gauge and progress calculations for calorie tracking UI.
enum CalorieGoalCalculator {
    /// The gauge maximum value — uses goal if set, otherwise intake.
    static func gaugeRange(intake: Double, goal: Double) -> Double {
        let range = goal > 0 ? goal : intake
        return max(range, 1)
    }

    /// Normalized progress (0.0–1.0) for gauge display.
    static func normalizedProgress(intake: Double, goal: Double) -> Double {
        let range = gaugeRange(intake: intake, goal: goal)
        let clamped = min(max(intake, 0), range)
        return clamped / range
    }

    /// Remaining calories toward goal. Negative means over goal.
    static func remaining(intake: Double, goal: Double) -> Double {
        goal - intake
    }
}
