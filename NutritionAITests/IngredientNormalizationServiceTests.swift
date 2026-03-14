import XCTest
@testable import NutritionAI

final class IngredientNormalizationServiceTests: XCTestCase {
    func testBasicNormalization() {
        let result = IngredientNormalizationService.normalize("  Chicken Breast  ")
        XCTAssertTrue(result.contains("chicken"))
        XCTAssertFalse(result.hasPrefix(" "))
    }

    func testExactSynonymReplacement() {
        let result = IngredientNormalizationService.normalize("chicken breast")
        XCTAssertEqual(result, "chicken, broilers or fryers, breast, meat only, cooked, roasted")
    }

    func testPlainRiceMapsToCooked() {
        let result = IngredientNormalizationService.normalize("rice")
        XCTAssertEqual(result, "rice, white, long-grain, cooked")
    }

    func testModifierRemovalThenExactMatch() {
        let result = IngredientNormalizationService.normalize("grilled chicken breast")
        XCTAssertEqual(result, "chicken, broilers or fryers, breast, meat only, cooked, roasted")
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
        XCTAssertFalse(result.contains("  "))
    }

    func testCommonStaples() {
        XCTAssertTrue(IngredientNormalizationService.normalize("egg").contains("egg"))
        XCTAssertTrue(IngredientNormalizationService.normalize("pasta").contains("pasta"))
        XCTAssertTrue(IngredientNormalizationService.normalize("banana").contains("banana"))
        XCTAssertTrue(IngredientNormalizationService.normalize("milk").contains("milk"))
    }
}
