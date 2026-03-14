import Foundation

/// JSON file-backed persistence for saved meals.
actor LocalMealHistoryRepository: MealHistoryRepository {
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dir = appSupport.appendingPathComponent("NutritionAI", isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            self.fileURL = dir.appendingPathComponent("meals.json")
        }
    }

    func loadAll() async -> [SavedMeal] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([SavedMeal].self, from: data)
        } catch {
            print("[MealHistory] Load failed: \(error)")
            return []
        }
    }

    func save(_ meals: [SavedMeal]) async {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(meals)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[MealHistory] Save failed: \(error)")
        }
    }
}
