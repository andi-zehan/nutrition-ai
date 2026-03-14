import Foundation

/// Contract for meal history persistence.
protocol MealHistoryRepository: Sendable {
    func loadAll() async -> [SavedMeal]
    func save(_ meals: [SavedMeal]) async
}

/// In-memory store with persistence backing, aggregation, and retention.
@MainActor
final class MealHistoryStore: ObservableObject {
    @Published private(set) var meals: [SavedMeal] = []

    private nonisolated(unsafe) let repository: MealHistoryRepository

    init(repository: MealHistoryRepository) {
        self.repository = repository
    }

    func load() async {
        meals = await repository.loadAll()
        meals.sort { $0.savedAt > $1.savedAt }
    }

    func add(_ meal: SavedMeal) async {
        meals.insert(meal, at: 0)
        await persist()
    }

    func delete(id: UUID) async {
        meals.removeAll { $0.id == id }
        await persist()
    }

    func meal(for id: UUID) -> SavedMeal? {
        meals.first { $0.id == id }
    }

    /// Build a trend snapshot for a date range.
    func snapshot(for range: TrendRange, referenceDate: Date = Date()) -> TrendSnapshot {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: referenceDate)

        let windowStart: Date
        switch range {
        case .today:
            windowStart = startOfToday
        case .last7Days:
            windowStart = calendar.date(byAdding: .day, value: -6, to: startOfToday)!
        case .last30Days:
            windowStart = calendar.date(byAdding: .day, value: -29, to: startOfToday)!
        }

        let windowMeals = meals.filter { $0.savedAt >= windowStart }

        let totals = windowMeals.reduce(NutritionTotals.zero) { result, meal in
            result + meal.nutrition
        }

        let uniqueDays = Set(windowMeals.map { calendar.startOfDay(for: $0.savedAt) }).count

        return TrendSnapshot(
            range: range,
            totalNutrition: totals,
            activeDays: uniqueDays,
            mealCount: windowMeals.count
        )
    }

    /// Meals for a specific calendar day.
    func meals(for date: Date) -> [SavedMeal] {
        let calendar = Calendar.current
        return meals.filter { calendar.isDate($0.savedAt, inSameDayAs: date) }
    }

    /// Replace entire meal list (used by retention cleanup).
    func replaceAll(_ updated: [SavedMeal]) async {
        meals = updated.sorted { $0.savedAt > $1.savedAt }
        await persist()
    }

    private func persist() async {
        await repository.save(meals)
    }
}
