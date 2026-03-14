import SwiftUI

struct IngredientRowView: View {
    @Binding var ingredient: IngredientDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Ingredient name", text: $ingredient.name)
                .font(.headline)

            HStack(spacing: 12) {
                TextField("Qty", value: $ingredient.quantity, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .frame(width: 70)
                    .textFieldStyle(.roundedBorder)

                Picker("Unit", selection: $ingredient.unit) {
                    ForEach(IngredientUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding(.vertical, 4)
    }
}
