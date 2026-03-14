import XCTest

final class NutritionAIUITests: XCTestCase {
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()
        // Onboarding should be visible on first launch
        XCTAssertTrue(app.staticTexts["NutritionAI"].exists)
    }
}
