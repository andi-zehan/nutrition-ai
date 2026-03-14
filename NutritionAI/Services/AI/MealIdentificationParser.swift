import Foundation

/// Parses OpenRouter chat completion responses into ingredient drafts.
enum MealIdentificationParser {
    /// Parse a chat completion response body into ingredient drafts.
    static func parse(_ data: Data) throws -> [IngredientDraft] {
        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)

        guard let content = response.choices.first?.message.content else {
            throw MealIdentificationError.invalidResponse
        }

        guard let jsonData = content.data(using: .utf8) else {
            throw MealIdentificationError.malformedJSON
        }

        let result = try JSONDecoder().decode(IngredientListResponse.self, from: jsonData)

        guard !result.ingredients.isEmpty else {
            throw MealIdentificationError.noIngredientsFound
        }

        return result.ingredients.map { raw in
            IngredientDraft(
                name: raw.name.trimmingCharacters(in: .whitespacesAndNewlines),
                quantity: max(raw.quantity, 0),
                unit: IngredientUnit(rawValue: raw.unit) ?? .grams
            )
        }
    }
}

// MARK: - Response Models

private struct ChatCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String?
    }
}

private struct IngredientListResponse: Decodable {
    let ingredients: [RawIngredient]

    struct RawIngredient: Decodable {
        let name: String
        let quantity: Double
        let unit: String
    }
}
