import XCTest
@testable import NutritionAI

final class MealRetentionServiceTests: XCTestCase {
    let service = MealRetentionService(photoRetentionDays: 30, mealRetentionDays: 365)

    func testMealsWithinRetentionAreKept() {
        let meal = makeMeal(daysAgo: 10)
        let result = service.applyRetention(to: [meal])
        XCTAssertEqual(result.count, 1)
    }

    func testMealsBeyond365DaysAreRemoved() {
        let meal = makeMeal(daysAgo: 400)
        let result = service.applyRetention(to: [meal])
        XCTAssertEqual(result.count, 0)
    }

    func testPhotoDataStrippedAfter30Days() {
        let meal = makeMeal(daysAgo: 35, withPhoto: true)
        let result = service.applyRetention(to: [meal])
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result.first?.photoData)
        XCTAssertNil(result.first?.thumbnailData)
    }

    func testPhotoDataKeptWithin30Days() {
        let meal = makeMeal(daysAgo: 5, withPhoto: true)
        let result = service.applyRetention(to: [meal])
        XCTAssertEqual(result.count, 1)
        XCTAssertNotNil(result.first?.photoData)
    }

    func testMealDataPreservedWhenPhotoStripped() {
        let meal = makeMeal(daysAgo: 35, withPhoto: true)
        let result = service.applyRetention(to: [meal])
        XCTAssertEqual(result.first?.nutrition.calories, meal.nutrition.calories)
        XCTAssertEqual(result.first?.ingredients.count, meal.ingredients.count)
    }

    private func makeMeal(daysAgo: Int, withPhoto: Bool = false) -> SavedMeal {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        return SavedMeal(
            savedAt: date,
            inputType: withPhoto ? .photo : .text,
            textInput: "Test meal",
            ingredients: [IngredientDraft(name: "Chicken", quantity: 200, unit: .grams)],
            nutrition: NutritionTotals(calories: 400, proteinGrams: 40, carbsGrams: 10, fatGrams: 15),
            photoData: withPhoto ? Data([0x00]) : nil,
            thumbnailData: withPhoto ? Data([0x00]) : nil,
            photoRetentionDays: 30
        )
    }
}
