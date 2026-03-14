import Foundation
import UIKit

/// How the meal was initially captured.
enum MealInputType: String, Codable {
    case photo
    case text
}

/// In-progress meal before calculation and save.
struct MealDraft {
    var inputType: MealInputType
    var photo: UIImage?
    var textHint: String
    var textDescription: String
    var ingredients: [IngredientDraft]

    init(
        inputType: MealInputType = .text,
        photo: UIImage? = nil,
        textHint: String = "",
        textDescription: String = "",
        ingredients: [IngredientDraft] = []
    ) {
        self.inputType = inputType
        self.photo = photo
        self.textHint = textHint
        self.textDescription = textDescription
        self.ingredients = ingredients
    }
}
