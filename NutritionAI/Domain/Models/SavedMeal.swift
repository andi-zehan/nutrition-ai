import Foundation

/// A persisted meal with nutrition data and retention-aware photo storage.
struct SavedMeal: Identifiable, Codable, Equatable, Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: SavedMeal, rhs: SavedMeal) -> Bool { lhs.id == rhs.id }

    let id: UUID
    let savedAt: Date
    let inputType: MealInputType
    let textInput: String
    let ingredients: [IngredientDraft]
    let nutrition: NutritionTotals
    var photoData: Data?
    var thumbnailData: Data?
    let photoExpiresAt: Date?

    /// Whether stored photo data has expired.
    var isPhotoExpired: Bool {
        guard let expires = photoExpiresAt else { return true }
        return Date() > expires
    }

    init(
        id: UUID = UUID(),
        savedAt: Date = Date(),
        inputType: MealInputType,
        textInput: String,
        ingredients: [IngredientDraft],
        nutrition: NutritionTotals,
        photoData: Data? = nil,
        thumbnailData: Data? = nil,
        photoRetentionDays: Int = 30
    ) {
        self.id = id
        self.savedAt = savedAt
        self.inputType = inputType
        self.textInput = textInput
        self.ingredients = ingredients
        self.nutrition = nutrition
        self.photoData = photoData
        self.thumbnailData = thumbnailData
        self.photoExpiresAt = photoData != nil
            ? Calendar.current.date(byAdding: .day, value: photoRetentionDays, to: savedAt)
            : nil
    }
}
