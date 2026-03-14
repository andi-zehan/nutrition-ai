import Foundation

/// Shared dependency container for all app services.
@MainActor
final class AppEnvironment: ObservableObject {
    let mealHistoryStore: MealHistoryStore
    let retentionService: MealRetentionService

    @Published var bodyMetrics: BodyMetrics? {
        didSet { persistBodyMetrics() }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    var dailyCalorieGoal: Double? {
        bodyMetrics?.dailyCalorieGoal
    }

    init() {
        let repository = LocalMealHistoryRepository()
        self.mealHistoryStore = MealHistoryStore(repository: repository)
        self.retentionService = MealRetentionService()
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.bodyMetrics = Self.loadBodyMetrics()
    }

    func performStartupTasks() async {
        await mealHistoryStore.load()
        // Apply retention on launch
        let cleaned = retentionService.applyRetention(to: mealHistoryStore.meals)
        if cleaned.count != mealHistoryStore.meals.count {
            await mealHistoryStore.replaceAll(cleaned)
        }
    }

    // MARK: - Body Metrics Persistence

    private static func loadBodyMetrics() -> BodyMetrics? {
        guard let data = UserDefaults.standard.data(forKey: "bodyMetrics") else { return nil }
        return try? JSONDecoder().decode(BodyMetrics.self, from: data)
    }

    private func persistBodyMetrics() {
        guard let metrics = bodyMetrics else {
            UserDefaults.standard.removeObject(forKey: "bodyMetrics")
            return
        }
        if let data = try? JSONEncoder().encode(metrics) {
            UserDefaults.standard.set(data, forKey: "bodyMetrics")
        }
    }
}
