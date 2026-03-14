import SwiftUI

struct MealDetailView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    let meal: SavedMeal
    let onDuplicate: () -> Void
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Photo if available
                if let photoData = meal.photoData, !meal.isPhotoExpired,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Timestamp
                Text(meal.savedAt.formatted(.dateTime.weekday(.wide).month(.wide).day().hour().minute()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Original text input
                if !meal.textInput.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(meal.textInput)
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                // Nutrition totals
                nutritionCard

                // Ingredients
                ingredientsList

                // Actions
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Meal Detail")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Meal?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await environment.mealHistoryStore.delete(id: meal.id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var nutritionCard: some View {
        VStack(spacing: 8) {
            Text("\(Int(meal.nutrition.calories)) kcal")
                .font(.title.bold())

            HStack(spacing: 16) {
                macroLabel("Protein", grams: meal.nutrition.proteinGrams, color: .orange)
                macroLabel("Carbs", grams: meal.nutrition.carbsGrams, color: .blue)
                macroLabel("Fat", grams: meal.nutrition.fatGrams, color: .red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func macroLabel(_ label: String, grams: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(color)
            Text(String(format: "%.1fg", grams))
                .font(.subheadline.bold())
        }
    }

    private var ingredientsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)

            ForEach(meal.ingredients) { ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text("\(String(format: "%.1f", ingredient.quantity)) \(ingredient.unit.displayName)")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                onDuplicate()
            } label: {
                Label("Duplicate as New Meal", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete Meal", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
}
