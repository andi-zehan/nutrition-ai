import Foundation

/// Enforces photo (30-day) and meal (365-day) retention policies.
struct MealRetentionService {
    let photoRetentionDays: Int
    let mealRetentionDays: Int

    init(
        photoRetentionDays: Int = AppConfig.photoRetentionDays,
        mealRetentionDays: Int = AppConfig.mealRetentionDays
    ) {
        self.photoRetentionDays = photoRetentionDays
        self.mealRetentionDays = mealRetentionDays
    }

    /// Apply retention rules to a list of meals, returning the cleaned list.
    func applyRetention(to meals: [SavedMeal], referenceDate: Date = Date()) -> [SavedMeal] {
        let calendar = Calendar.current

        let mealCutoff = calendar.date(byAdding: .day, value: -mealRetentionDays, to: referenceDate)!

        return meals.compactMap { meal in
            // Remove meals older than retention window entirely
            guard meal.savedAt > mealCutoff else { return nil }

            // Strip expired photo data but keep the meal
            if meal.isPhotoExpired && (meal.photoData != nil || meal.thumbnailData != nil) {
                var cleaned = meal
                cleaned.photoData = nil
                cleaned.thumbnailData = nil
                return cleaned
            }

            return meal
        }
    }
}
