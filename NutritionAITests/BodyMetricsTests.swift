import XCTest
@testable import NutritionAI

final class BodyMetricsTests: XCTestCase {
    func testBMRMale() {
        let metrics = BodyMetrics(
            weightKg: 80, heightCm: 180, age: 30,
            sex: .male, activityLevel: .sedentary, weightGoal: .maintain
        )
        // Mifflin-St Jeor: (10*80) + (6.25*180) - (5*30) + 5 = 800 + 1125 - 150 + 5 = 1780
        XCTAssertEqual(metrics.bmr, 1780, accuracy: 0.1)
    }

    func testBMRFemale() {
        let metrics = BodyMetrics(
            weightKg: 65, heightCm: 165, age: 25,
            sex: .female, activityLevel: .sedentary, weightGoal: .maintain
        )
        // (10*65) + (6.25*165) - (5*25) - 161 = 650 + 1031.25 - 125 - 161 = 1395.25
        XCTAssertEqual(metrics.bmr, 1395.25, accuracy: 0.1)
    }

    func testTDEEWithActivityLevel() {
        let metrics = BodyMetrics(
            weightKg: 80, heightCm: 180, age: 30,
            sex: .male, activityLevel: .moderatelyActive, weightGoal: .maintain
        )
        XCTAssertEqual(metrics.tdee, 1780 * 1.55, accuracy: 0.1)
    }

    func testDailyCalorieGoalWithWeightLoss() {
        let metrics = BodyMetrics(
            weightKg: 80, heightCm: 180, age: 30,
            sex: .male, activityLevel: .moderatelyActive, weightGoal: .lose05kg
        )
        let expected = (1780 * 1.55) - 500
        XCTAssertEqual(metrics.dailyCalorieGoal, expected, accuracy: 0.1)
    }

    func testDailyCalorieGoalFloorAt1200() {
        let metrics = BodyMetrics(
            weightKg: 50, heightCm: 150, age: 60,
            sex: .female, activityLevel: .sedentary, weightGoal: .lose1kg
        )
        // BMR will be low, TDEE with sedentary is BMR*1.2, minus 1000 could go below 1200
        XCTAssertGreaterThanOrEqual(metrics.dailyCalorieGoal, 1200)
    }

    func testBMI() {
        let metrics = BodyMetrics(
            weightKg: 75, heightCm: 175, age: 30,
            sex: .male, activityLevel: .sedentary, weightGoal: .maintain
        )
        // 75 / (1.75^2) = 75 / 3.0625 = 24.49
        XCTAssertEqual(metrics.bmi, 24.49, accuracy: 0.1)
    }
}
