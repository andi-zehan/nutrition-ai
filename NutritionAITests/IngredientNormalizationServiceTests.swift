import XCTest
@testable import NutritionAI

final class IngredientNormalizationServiceTests: XCTestCase {
    func testBasicNormalization() {
        let result = IngredientNormalizationService.normalize("  Chicken Breast  ")
        XCTAssertTrue(result.contains("chicken"))
        XCTAssertFalse(result.hasPrefix(" "))
    }

    func testSynonymReplacement() {
        let result = IngredientNormalizationService.normalize("chicken breast")
        XCTAssertEqual(result, "chicken, broilers or fryers, breast, meat only")
    }

    func testModifierRemoval() {
        let result = IngredientNormalizationService.normalize("fresh organic spinach")
        XCTAssertEqual(result, "spinach, raw")
    }

    func testUnknownIngredientPassesThrough() {
        let result = IngredientNormalizationService.normalize("dragon fruit")
        XCTAssertEqual(result, "dragon fruit")
    }

    func testExtraWhitespaceCollapsed() {
        let result = IngredientNormalizationService.normalize("  large   potato  ")
        // "large " is removed, "potato" is mapped
        XCTAssertFalse(result.contains("  "))
    }
}
