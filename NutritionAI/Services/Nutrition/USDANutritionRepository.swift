import Foundation

/// USDA FoodData Central API-backed nutrition lookup.
final class USDANutritionRepository: NutritionLookupService, @unchecked Sendable {
    private let apiKey: String
    private let baseURL: URL
    private let session: URLSession

    init(
        apiKey: String = AppConfig.usdaAPIKey,
        baseURL: URL = AppConfig.usdaBaseURL,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = session
    }

    func lookup(ingredientName: String) async throws -> NutritionPer100g? {
        let normalized = IngredientNormalizationService.normalize(ingredientName)
        let results = try await search(query: normalized)

        guard let best = results.first else { return nil }

        return try await fetchNutrition(fdcId: best.id, foodName: best.name)
    }

    func search(query: String) async throws -> [FoodSearchResult] {
        var components = URLComponents(url: baseURL.appendingPathComponent("foods/search"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "dataType", value: "Foundation,SR Legacy"),
            URLQueryItem(name: "pageSize", value: "5")
        ]

        guard let url = components.url else {
            throw NutritionLookupError.apiError("Invalid search URL")
        }

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NutritionLookupError.apiError("USDA search failed")
        }

        let searchResponse = try JSONDecoder().decode(USDASearchResponse.self, from: data)

        return searchResponse.foods.map { food in
            FoodSearchResult(
                id: food.fdcId,
                name: food.description,
                dataType: food.dataType
            )
        }
    }

    // MARK: - Private

    private func fetchNutrition(fdcId: Int, foodName: String) async throws -> NutritionPer100g {
        var components = URLComponents(url: baseURL.appendingPathComponent("food/\(fdcId)"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "nutrients", value: "208,203,205,204") // Energy, Protein, Carbs, Fat
        ]

        guard let url = components.url else {
            throw NutritionLookupError.apiError("Invalid food URL")
        }

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NutritionLookupError.apiError("USDA food lookup failed")
        }

        let foodResponse = try JSONDecoder().decode(USDAFoodResponse.self, from: data)

        var calories = 0.0
        var protein = 0.0
        var carbs = 0.0
        var fat = 0.0

        for nutrient in foodResponse.foodNutrients {
            let id = nutrient.nutrient?.id ?? nutrient.number.flatMap(Int.init) ?? 0
            let amount = nutrient.amount ?? 0

            switch id {
            case 1008, 208: calories = amount  // Energy (kcal)
            case 1003, 203: protein = amount   // Protein
            case 1005, 205: carbs = amount     // Carbohydrates
            case 1004, 204: fat = amount       // Total fat
            default: break
            }
        }

        return NutritionPer100g(
            foodName: foodName,
            calories: calories,
            proteinGrams: protein,
            carbsGrams: carbs,
            fatGrams: fat
        )
    }
}

// MARK: - USDA API Response Models

private struct USDASearchResponse: Decodable {
    let foods: [USDASearchFood]

    struct USDASearchFood: Decodable {
        let fdcId: Int
        let description: String
        let dataType: String?
    }
}

private struct USDAFoodResponse: Decodable {
    let foodNutrients: [USDAFoodNutrient]

    struct USDAFoodNutrient: Decodable {
        let nutrient: NutrientInfo?
        let amount: Double?
        let number: String?

        struct NutrientInfo: Decodable {
            let id: Int?
        }
    }
}
