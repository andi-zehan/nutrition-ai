import Foundation

/// Normalizes ingredient names and applies synonym cleanup before USDA search.
enum IngredientNormalizationService {
    /// Clean up an ingredient name for better USDA search results.
    static func normalize(_ name: String) -> String {
        var result = name
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove common modifiers that don't affect nutrition significantly
        for modifier in removableModifiers {
            result = result.replacingOccurrences(of: modifier, with: "")
        }

        // Clean up extra whitespace
        result = result.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        // Try exact match first, then partial match
        if let exact = exactSynonyms[result] {
            return exact
        }

        // Try partial matching — check if any synonym key is contained in the result
        for (pattern, replacement) in partialSynonyms {
            if result.contains(pattern) {
                return replacement
            }
        }

        return result
    }

    // MARK: - Exact matches (checked first)

    private static let exactSynonyms: [String: String] = [
        // Grains & starches
        "rice": "rice, white, long-grain, cooked",
        "white rice": "rice, white, long-grain, cooked",
        "brown rice": "rice, brown, long-grain, cooked",
        "pasta": "pasta, cooked, enriched",
        "spaghetti": "pasta, cooked, enriched",
        "noodles": "noodles, egg, cooked, enriched",
        "bread": "bread, white, commercially prepared",
        "white bread": "bread, white, commercially prepared",
        "wheat bread": "bread, whole-wheat, commercially prepared",
        "oatmeal": "cereals, oats, regular and quick, cooked",
        "oats": "cereals, oats, regular and quick, cooked",
        "quinoa": "quinoa, cooked",
        "couscous": "couscous, cooked",
        "tortilla": "tortillas, ready-to-bake or -fry, flour",

        // Proteins
        "chicken": "chicken, broilers or fryers, breast, meat only, cooked, roasted",
        "chicken breast": "chicken, broilers or fryers, breast, meat only, cooked, roasted",
        "chicken thigh": "chicken, broilers or fryers, thigh, meat only, cooked, roasted",
        "beef": "beef, ground, 85% lean meat / 15% fat, cooked",
        "ground beef": "beef, ground, 85% lean meat / 15% fat, cooked",
        "steak": "beef, top sirloin, steak, cooked",
        "pork": "pork, fresh, loin, whole, cooked, roasted",
        "bacon": "pork, cured, bacon, cooked",
        "ham": "ham, sliced, regular",
        "turkey": "turkey, whole, breast, meat only, cooked, roasted",
        "salmon": "fish, salmon, atlantic, cooked, dry heat",
        "tuna": "fish, tuna, light, canned in water, drained",
        "shrimp": "crustaceans, shrimp, cooked",
        "tofu": "tofu, firm, prepared with calcium sulfate",
        "egg": "egg, whole, cooked, scrambled",
        "eggs": "egg, whole, cooked, scrambled",

        // Dairy
        "milk": "milk, whole, 3.25% milkfat",
        "whole milk": "milk, whole, 3.25% milkfat",
        "skim milk": "milk, nonfat, fluid",
        "cheese": "cheese, cheddar",
        "cheddar": "cheese, cheddar",
        "mozzarella": "cheese, mozzarella, whole milk",
        "yogurt": "yogurt, plain, whole milk",
        "butter": "butter, salted",
        "cream cheese": "cream cheese",

        // Vegetables
        "broccoli": "broccoli, cooked, boiled, drained",
        "spinach": "spinach, raw",
        "tomato": "tomatoes, red, ripe, raw",
        "tomatoes": "tomatoes, red, ripe, raw",
        "potato": "potatoes, boiled, cooked without skin",
        "potatoes": "potatoes, boiled, cooked without skin",
        "sweet potato": "sweet potato, cooked, baked in skin",
        "carrot": "carrots, raw",
        "carrots": "carrots, raw",
        "onion": "onions, raw",
        "garlic": "garlic, raw",
        "pepper": "peppers, sweet, red, raw",
        "bell pepper": "peppers, sweet, red, raw",
        "corn": "corn, sweet, yellow, cooked, boiled, drained",
        "peas": "peas, green, cooked, boiled, drained",
        "lettuce": "lettuce, iceberg, raw",
        "cucumber": "cucumber, with peel, raw",
        "mushroom": "mushrooms, white, raw",
        "mushrooms": "mushrooms, white, raw",
        "zucchini": "squash, summer, zucchini, cooked, boiled, drained",
        "cabbage": "cabbage, common, cooked, boiled, drained",
        "cauliflower": "cauliflower, cooked, boiled, drained",
        "green beans": "beans, snap, green, cooked, boiled, drained",
        "kale": "kale, raw",
        "asparagus": "asparagus, cooked, boiled, drained",
        "celery": "celery, raw",
        "eggplant": "eggplant, cooked, boiled, drained",

        // Fruits
        "apple": "apples, raw, with skin",
        "banana": "bananas, raw",
        "orange": "oranges, raw, all commercial varieties",
        "strawberry": "strawberries, raw",
        "strawberries": "strawberries, raw",
        "blueberries": "blueberries, raw",
        "grapes": "grapes, red or green, raw",
        "watermelon": "watermelon, raw",
        "mango": "mangos, raw",
        "pineapple": "pineapple, raw, all varieties",
        "avocado": "avocados, raw, all commercial varieties",
        "lemon": "lemons, raw, without peel",
        "peach": "peaches, raw",
        "pear": "pears, raw",
        "cherry": "cherries, sweet, raw",
        "cherries": "cherries, sweet, raw",
        "kiwi": "kiwifruit, green, raw",

        // Oils & fats
        "olive oil": "oil, olive, salad or cooking",
        "vegetable oil": "oil, vegetable, canola",
        "coconut oil": "oil, coconut",

        // Legumes & nuts
        "beans": "beans, black, mature seeds, cooked, boiled",
        "black beans": "beans, black, mature seeds, cooked, boiled",
        "lentils": "lentils, mature seeds, cooked, boiled",
        "chickpeas": "chickpeas, mature seeds, cooked, boiled",
        "peanut butter": "peanut butter, smooth style",
        "almonds": "nuts, almonds",
        "walnuts": "nuts, walnuts, english",

        // Condiments & sauces
        "sugar": "sugars, granulated",
        "honey": "honey",
        "salt": "salt, table",
        "soy sauce": "soy sauce, made from soy and wheat",
        "ketchup": "catsup",
        "mayonnaise": "salad dressing, mayonnaise, regular",
        "mustard": "mustard, prepared, yellow",

        // Common meals/sauces
        "bolognese sauce": "sauce, pasta, spaghetti/marinara, ready-to-serve",
        "tomato sauce": "sauce, pasta, spaghetti/marinara, ready-to-serve",
        "pesto": "sauce, pesto, ready-to-serve",
    ]

    // MARK: - Partial matches (checked if no exact match)

    private static let partialSynonyms: [(String, String)] = [
        ("chicken breast", "chicken, broilers or fryers, breast, meat only, cooked, roasted"),
        ("chicken thigh", "chicken, broilers or fryers, thigh, meat only, cooked, roasted"),
        ("ground beef", "beef, ground, 85% lean meat / 15% fat, cooked"),
        ("sweet potato", "sweet potato, cooked, baked in skin"),
        ("cream cheese", "cream cheese"),
        ("peanut butter", "peanut butter, smooth style"),
        ("olive oil", "oil, olive, salad or cooking"),
        ("soy sauce", "soy sauce, made from soy and wheat"),
        ("green beans", "beans, snap, green, cooked, boiled, drained"),
        ("bell pepper", "peppers, sweet, red, raw"),
        ("black beans", "beans, black, mature seeds, cooked, boiled"),
    ]

    private static let removableModifiers = [
        "fresh ", "organic ", "homemade ", "store-bought ",
        "chopped ", "diced ", "sliced ", "minced ",
        "grilled ", "baked ", "fried ", "steamed ", "roasted ",
        "sauteed ", "raw ", "cooked ", "boiled ", "blanched ",
        "frozen ", "canned ", "dried ",
        "large ", "medium ", "small ",
        "thin ", "thick ",
    ]
}
