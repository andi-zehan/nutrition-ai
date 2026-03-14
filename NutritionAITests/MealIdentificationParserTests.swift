import XCTest
@testable import NutritionAI

final class MealIdentificationParserTests: XCTestCase {
    func testParsesValidResponse() throws {
        let json = """
        {
            "choices": [{
                "message": {
                    "content": "{\\"ingredients\\": [{\\"name\\": \\"chicken breast\\", \\"quantity\\": 200, \\"unit\\": \\"grams\\"}, {\\"name\\": \\"white rice\\", \\"quantity\\": 1, \\"unit\\": \\"cups\\"}]}"
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let ingredients = try MealIdentificationParser.parse(data)
        XCTAssertEqual(ingredients.count, 2)
        XCTAssertEqual(ingredients[0].name, "chicken breast")
        XCTAssertEqual(ingredients[0].quantity, 200)
        XCTAssertEqual(ingredients[0].unit, .grams)
        XCTAssertEqual(ingredients[1].name, "white rice")
        XCTAssertEqual(ingredients[1].unit, .cups)
    }

    func testThrowsOnEmptyIngredients() {
        let json = """
        {
            "choices": [{
                "message": {
                    "content": "{\\"ingredients\\": []}"
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try MealIdentificationParser.parse(data)) { error in
            XCTAssertTrue(error is MealIdentificationError)
        }
    }

    func testThrowsOnMalformedJSON() {
        let json = """
        {
            "choices": [{
                "message": {
                    "content": "not json at all"
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try MealIdentificationParser.parse(data))
    }

    func testThrowsOnMissingContent() {
        let json = """
        {
            "choices": [{
                "message": {
                    "content": null
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try MealIdentificationParser.parse(data))
    }

    func testNegativeQuantityClampedToZero() throws {
        let json = """
        {
            "choices": [{
                "message": {
                    "content": "{\\"ingredients\\": [{\\"name\\": \\"salt\\", \\"quantity\\": -1, \\"unit\\": \\"tsp\\"}]}"
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let ingredients = try MealIdentificationParser.parse(data)
        XCTAssertEqual(ingredients[0].quantity, 0)
    }

    func testUnknownUnitDefaultsToGrams() throws {
        let json = """
        {
            "choices": [{
                "message": {
                    "content": "{\\"ingredients\\": [{\\"name\\": \\"flour\\", \\"quantity\\": 100, \\"unit\\": \\"ounces\\"}]}"
                }
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let ingredients = try MealIdentificationParser.parse(data)
        XCTAssertEqual(ingredients[0].unit, .grams)
    }
}
