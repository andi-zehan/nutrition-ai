import SwiftUI

struct NutritionResultsView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    let result: CalculationResult
    let onSaved: () -> Void
    @State private var isSaving = false
    @State private var didSave = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Calorie total
                VStack(spacing: 4) {
                    Text("\(Int(result.nutrition.calories))")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                    Text("calories")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)

                // Macros
                HStack(spacing: 24) {
                    macroColumn("Protein", grams: result.nutrition.proteinGrams, color: .orange)
                    macroColumn("Carbs", grams: result.nutrition.carbsGrams, color: .blue)
                    macroColumn("Fat", grams: result.nutrition.fatGrams, color: .red)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Ingredient summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)

                    ForEach(result.ingredients) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Text("\(String(format: "%.1f", ingredient.quantity)) \(ingredient.unit.displayName)")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Save button
                Button {
                    Task { await saveMeal() }
                } label: {
                    Text(didSave ? "Saved!" : "Save Meal")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isSaving || didSave)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func macroColumn(_ label: String, grams: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f", grams))
                .font(.title2.bold())
            Text("g")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private func saveMeal() async {
        isSaving = true

        var photoData: Data?
        var thumbnailData: Data?

        if let photo = result.draft.photo {
            photoData = ImageResizer.jpegData(of: ImageResizer.resize(image: photo, longest: 1600))
            thumbnailData = ImageResizer.jpegData(of: ImageResizer.resize(image: photo, longest: 320))
        }

        let textInput = result.draft.inputType == .text
            ? result.draft.textDescription
            : result.draft.textHint

        let meal = SavedMeal(
            inputType: result.draft.inputType,
            textInput: textInput,
            ingredients: result.ingredients,
            nutrition: result.nutrition,
            photoData: photoData,
            thumbnailData: thumbnailData
        )

        await environment.mealHistoryStore.add(meal)
        isSaving = false
        didSave = true

        // Brief delay then navigate back
        try? await Task.sleep(for: .seconds(0.5))
        onSaved()
    }
}
