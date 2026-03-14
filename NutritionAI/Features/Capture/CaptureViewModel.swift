import SwiftUI

/// Manages capture flow state: photo/text input → AI identification → draft creation.
@MainActor
final class CaptureViewModel: ObservableObject {
    @Published var capturedPhoto: UIImage?
    @Published var textHint: String = ""
    @Published var textDescription: String = ""
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    @Published var draft: MealDraft?

    private nonisolated(unsafe) let identificationService: MealIdentificationService

    init(identificationService: MealIdentificationService? = nil) {
        self.identificationService = identificationService
            ?? OpenRouterMealIdentificationService()
    }

    /// Analyze a captured photo with optional hint.
    func analyzePhoto() async {
        guard let photo = capturedPhoto else { return }
        isAnalyzing = true
        errorMessage = nil

        do {
            let ingredients = try await identificationService.identify(
                photo: photo,
                hint: textHint.isEmpty ? nil : textHint
            )
            draft = MealDraft(
                inputType: .photo,
                photo: photo,
                textHint: textHint,
                ingredients: ingredients
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    /// Analyze a text-only meal description.
    func analyzeText() async {
        let text = textDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isAnalyzing = true
        errorMessage = nil

        do {
            let ingredients = try await identificationService.identify(text: text)
            draft = MealDraft(
                inputType: .text,
                textDescription: text,
                ingredients: ingredients
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    /// Create a draft from a duplicated meal's ingredients.
    func loadDuplicate(from meal: SavedMeal) {
        draft = MealDraft(
            inputType: meal.inputType,
            textDescription: meal.textInput,
            ingredients: meal.ingredients.map {
                IngredientDraft(name: $0.name, quantity: $0.quantity, unit: $0.unit)
            }
        )
    }

    func reset() {
        capturedPhoto = nil
        textHint = ""
        textDescription = ""
        isAnalyzing = false
        errorMessage = nil
        draft = nil
    }
}
