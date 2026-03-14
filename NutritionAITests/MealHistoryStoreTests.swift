import XCTest
@testable import NutritionAI

/// In-memory repository for testing.
actor InMemoryMealHistoryRepository: MealHistoryRepository {
    var stored: [SavedMeal] = []

    func loadAll() async -> [SavedMeal] { stored }

    func save(_ meals: [SavedMeal]) async { stored = meals }
}

@MainActor
final class MealHistoryStoreTests: XCTestCase {
    private var repository: InMemoryMealHistoryRepository!
    private var store: MealHistoryStore!

    override func setUp() async throws {
        repository = InMemoryMealHistoryRepository()
        store = MealHistoryStore(repository: repository)
    }

    func testAddMealAppearsInList() async {
        let meal = makeMeal()
        await store.add(meal)
        XCTAssertEqual(store.meals.count, 1)
        XCTAssertEqual(store.meals.first?.id, meal.id)
    }

    func testDeleteRemovesMeal() async {
        let meal = makeMeal()
        await store.add(meal)
        await store.delete(id: meal.id)
        XCTAssertTrue(store.meals.isEmpty)
    }

    func testSnapshotTodayOnlyIncludesToday() async {
        let todayMeal = makeMeal(daysAgo: 0, calories: 500)
        let yesterdayMeal = makeMeal(daysAgo: 1, calories: 300)
        await store.add(todayMeal)
        await store.add(yesterdayMeal)

        let snapshot = store.snapshot(for: .today)
        XCTAssertEqual(snapshot.totalNutrition.calories, 500)
        XCTAssertEqual(snapshot.mealCount, 1)
    }

    func testSnapshot7DaysIncludesWeek() async {
        let todayMeal = makeMeal(daysAgo: 0, calories: 500)
        let threeDaysAgo = makeMeal(daysAgo: 3, calories: 300)
        let tenDaysAgo = makeMeal(daysAgo: 10, calories: 200)
        await store.add(todayMeal)
        await store.add(threeDaysAgo)
        await store.add(tenDaysAgo)

        let snapshot = store.snapshot(for: .last7Days)
        XCTAssertEqual(snapshot.totalNutrition.calories, 800)
        XCTAssertEqual(snapshot.mealCount, 2)
        XCTAssertEqual(snapshot.activeDays, 2)
    }

    func testMealsForDateReturnsCorrectDay() async {
        let today = makeMeal(daysAgo: 0)
        let yesterday = makeMeal(daysAgo: 1)
        await store.add(today)
        await store.add(yesterday)

        let todayMeals = store.meals(for: Date())
        XCTAssertEqual(todayMeals.count, 1)
    }

    func testMealsSortedNewestFirst() async {
        let older = makeMeal(daysAgo: 2)
        let newer = makeMeal(daysAgo: 0)
        await store.add(older)
        await store.add(newer)

        XCTAssertEqual(store.meals.first?.id, newer.id)
    }

    private func makeMeal(daysAgo: Int = 0, calories: Double = 400) -> SavedMeal {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        return SavedMeal(
            savedAt: date,
            inputType: .text,
            textInput: "Test",
            ingredients: [IngredientDraft(name: "Chicken", quantity: 200, unit: .grams)],
            nutrition: NutritionTotals(calories: calories, proteinGrams: 30, carbsGrams: 10, fatGrams: 10)
        )
    }
}
