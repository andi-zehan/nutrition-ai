import Foundation

/// Normalizes ingredient names and applies synonym cleanup before USDA search.
enum IngredientNormalizationService {
    /// Clean up an ingredient name for better USDA search results.
    static func normalize(_ name: String) -> String {
        var result = name
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Apply synonym mappings
        for (pattern, replacement) in synonyms {
            if result.contains(pattern) {
                result = result.replacingOccurrences(of: pattern, with: replacement)
            }
        }

        // Remove common modifiers that don't affect nutrition significantly
        for modifier in removableModifiers {
            result = result.replacingOccurrences(of: modifier, with: "")
        }

        // Clean up extra whitespace
        result = result.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return result
    }

    private static let synonyms: [(String, String)] = [
        ("chicken breast", "chicken, broilers or fryers, breast, meat only"),
        ("chicken thigh", "chicken, broilers or fryers, thigh, meat only"),
        ("ground beef", "beef, ground, 80% lean meat / 20% fat"),
        ("white rice", "rice, white, long-grain, cooked"),
        ("brown rice", "rice, brown, long-grain, cooked"),
        ("whole milk", "milk, whole"),
        ("skim milk", "milk, nonfat"),
        ("olive oil", "oil, olive, salad or cooking"),
        ("butter", "butter, salted"),
        ("cheddar", "cheese, cheddar"),
        ("mozzarella", "cheese, mozzarella, whole milk"),
        ("white bread", "bread, white, commercially prepared"),
        ("wheat bread", "bread, whole-wheat, commercially prepared"),
        ("egg", "egg, whole, cooked, scrambled"),
        ("banana", "bananas, raw"),
        ("apple", "apples, raw, with skin"),
        ("broccoli", "broccoli, cooked, boiled"),
        ("spinach", "spinach, raw"),
        ("salmon", "fish, salmon, atlantic, cooked"),
        ("tuna", "fish, tuna, light, canned in water"),
        ("pasta", "pasta, cooked, enriched"),
        ("spaghetti", "pasta, cooked, enriched"),
        ("avocado", "avocados, raw, all commercial varieties"),
        ("potato", "potatoes, boiled, cooked without skin"),
        ("sweet potato", "sweet potato, cooked, baked in skin"),
        ("tomato", "tomatoes, red, ripe, raw"),
        ("carrot", "carrots, raw"),
        ("onion", "onions, raw"),
    ]

    private static let removableModifiers = [
        "fresh ", "organic ", "homemade ", "store-bought ",
        "chopped ", "diced ", "sliced ", "minced ",
        "grilled ", "baked ", "fried ", "steamed ", "roasted ",
        "large ", "medium ", "small ",
    ]
}
