import Foundation
import UIKit

/// OpenRouter-backed ingredient identification using GPT-4.1 Mini with strict JSON output.
final class OpenRouterMealIdentificationService: MealIdentificationService, @unchecked Sendable {
    private let apiKey: String
    private let model: String
    private let baseURL: URL
    private let session: URLSession

    init(
        apiKey: String = AppConfig.openRouterAPIKey,
        model: String = AppConfig.openRouterModel,
        baseURL: URL = AppConfig.openRouterBaseURL,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
        self.session = session
    }

    func identify(photo: UIImage, hint: String?) async throws -> [IngredientDraft] {
        let resized = ImageResizer.resize(image: photo, longest: 1024)
        guard let jpegData = ImageResizer.jpegData(of: resized) else {
            throw MealIdentificationError.invalidResponse
        }
        let base64 = jpegData.base64EncodedString()

        var userContent: [[String: Any]] = [
            [
                "type": "image_url",
                "image_url": ["url": "data:image/jpeg;base64,\(base64)"]
            ]
        ]

        let textPrompt = hint.flatMap { $0.isEmpty ? nil : $0 }
            .map { "Hint: \($0)" } ?? ""
        if !textPrompt.isEmpty {
            userContent.insert(["type": "text", "text": textPrompt], at: 0)
        }

        return try await sendRequest(userContent: userContent)
    }

    func identify(text: String) async throws -> [IngredientDraft] {
        let userContent: [[String: Any]] = [
            ["type": "text", "text": text]
        ]
        return try await sendRequest(userContent: userContent)
    }

    // MARK: - Private

    private func sendRequest(userContent: [[String: Any]]) async throws -> [IngredientDraft] {
        let url = baseURL.appendingPathComponent("chat/completions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("NutritionAI/1.0", forHTTPHeaderField: "HTTP-Referer")

        let body: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": Self.systemPrompt
                ],
                [
                    "role": "user",
                    "content": userContent
                ]
            ],
            "response_format": [
                "type": "json_schema",
                "json_schema": [
                    "name": "ingredient_list",
                    "strict": true,
                    "schema": Self.jsonSchema
                ]
            ],
            "temperature": 0.3,
            "max_tokens": 1024
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MealIdentificationError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw MealIdentificationError.networkError(
                NSError(domain: "OpenRouter", code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: errorBody])
            )
        }

        return try MealIdentificationParser.parse(data)
    }

    private static let systemPrompt = """
        You are a food analysis assistant. Given a meal photo or description, identify all \
        visible ingredients with estimated quantities and units. Be specific about ingredient \
        names (e.g., "chicken breast" not just "chicken"). Estimate realistic portions. \
        Use these units only: grams, ml, servings, cups, tbsp, tsp, slices, pieces. \
        Return JSON matching the required schema exactly.
        """

    private nonisolated(unsafe) static let jsonSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "ingredients": [
                "type": "array",
                "items": [
                    "type": "object",
                    "properties": [
                        "name": ["type": "string"],
                        "quantity": ["type": "number"],
                        "unit": [
                            "type": "string",
                            "enum": ["grams", "ml", "servings", "cups", "tbsp", "tsp", "slices", "pieces"]
                        ]
                    ],
                    "required": ["name", "quantity", "unit"],
                    "additionalProperties": false
                ]
            ]
        ],
        "required": ["ingredients"],
        "additionalProperties": false
    ]
}
