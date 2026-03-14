import Foundation
import UIKit

/// Contract for AI-backed ingredient identification.
protocol MealIdentificationService: Sendable {
    /// Identify ingredients from a photo and optional text hint.
    func identify(photo: UIImage, hint: String?) async throws -> [IngredientDraft]
    /// Identify ingredients from a text description.
    func identify(text: String) async throws -> [IngredientDraft]
}

enum MealIdentificationError: LocalizedError {
    case invalidResponse
    case malformedJSON
    case networkError(Error)
    case noIngredientsFound

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The AI returned an invalid response."
        case .malformedJSON: "Could not parse ingredient data from the AI response."
        case .networkError(let error): "Network error: \(error.localizedDescription)"
        case .noIngredientsFound: "No ingredients were detected. Try adding a description."
        }
    }
}
