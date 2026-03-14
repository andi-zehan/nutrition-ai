import SwiftUI

struct JournalView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var mealToDuplicate: SavedMeal?

    var body: some View {
        NavigationStack {
            Group {
                if environment.mealHistoryStore.meals.isEmpty {
                    ContentUnavailableView(
                        "No Meals Yet",
                        systemImage: "book.closed",
                        description: Text("Saved meals will appear here.")
                    )
                } else {
                    mealList
                }
            }
            .navigationTitle("Journal")
            .navigationDestination(item: $mealToDuplicate) { meal in
                IngredientReviewView(
                    draft: MealDraft(
                        inputType: meal.inputType,
                        textDescription: meal.textInput,
                        ingredients: meal.ingredients.map {
                            IngredientDraft(name: $0.name, quantity: $0.quantity, unit: $0.unit)
                        }
                    ),
                    onDismiss: { mealToDuplicate = nil }
                )
            }
        }
    }

    private var mealList: some View {
        List {
            ForEach(groupedMeals, id: \.date) { group in
                Section(group.label) {
                    ForEach(group.meals) { meal in
                        NavigationLink {
                            MealDetailView(meal: meal, onDuplicate: { mealToDuplicate = meal })
                        } label: {
                            MealRowView(meal: meal)
                        }
                    }
                    .onDelete { offsets in
                        Task {
                            for index in offsets {
                                await environment.mealHistoryStore.delete(id: group.meals[index].id)
                            }
                        }
                    }
                }
            }
        }
    }

    private var groupedMeals: [MealGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: environment.mealHistoryStore.meals) { meal in
            calendar.startOfDay(for: meal.savedAt)
        }
        return grouped.map { date, meals in
            MealGroup(date: date, meals: meals.sorted { $0.savedAt > $1.savedAt })
        }
        .sorted { $0.date > $1.date }
    }
}

private struct MealGroup {
    let date: Date
    let meals: [SavedMeal]

    var label: String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month(.wide).day().year())
        }
    }
}

private struct MealRowView: View {
    let meal: SavedMeal

    var body: some View {
        HStack(spacing: 12) {
            if let thumbData = meal.thumbnailData, !meal.isPhotoExpired,
               let uiImage = UIImage(data: thumbData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.textInput.isEmpty ? "Meal" : meal.textInput)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Text("\(Int(meal.nutrition.calories)) kcal")
                        .font(.subheadline.bold())
                    Text("\(meal.ingredients.count) items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(meal.savedAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
