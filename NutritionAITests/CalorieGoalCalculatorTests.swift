import XCTest
@testable import NutritionAI

final class CalorieGoalCalculatorTests: XCTestCase {
    func testNormalizedProgressCapsAtOne() {
        let progress = CalorieGoalCalculator.normalizedProgress(intake: 3000, goal: 2000)
        XCTAssertEqual(progress, 1.0)
    }

    func testNormalizedProgressZeroIntake() {
        let progress = CalorieGoalCalculator.normalizedProgress(intake: 0, goal: 2000)
        XCTAssertEqual(progress, 0.0)
    }

    func testGaugeRangeUsesGoalWhenPositive() {
        let range = CalorieGoalCalculator.gaugeRange(intake: 500, goal: 2000)
        XCTAssertEqual(range, 2000)
    }

    func testGaugeRangeUsesIntakeWhenNoGoal() {
        let range = CalorieGoalCalculator.gaugeRange(intake: 500, goal: 0)
        XCTAssertEqual(range, 500)
    }

    func testGaugeRangeMinimumIsOne() {
        let range = CalorieGoalCalculator.gaugeRange(intake: 0, goal: 0)
        XCTAssertEqual(range, 1)
    }

    func testRemainingCalories() {
        let remaining = CalorieGoalCalculator.remaining(intake: 1500, goal: 2000)
        XCTAssertEqual(remaining, 500)
    }

    func testOverGoalRemainingIsNegative() {
        let remaining = CalorieGoalCalculator.remaining(intake: 2500, goal: 2000)
        XCTAssertEqual(remaining, -500)
    }
}
