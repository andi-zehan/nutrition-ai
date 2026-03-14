import SwiftUI

struct IngredientReviewView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: IngredientReviewViewModel
    @State private var showAddIngredient = false
    @State private var navigateToResults = false
    let onDismiss: () -> Void

    init(draft: MealDraft, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: IngredientReviewViewModel(draft: draft))
        self.onDismiss = onDismiss
    }

    var body: some View {
        List {
            Section {
                ForEach($viewModel.ingredients) { $ingredient in
                    IngredientRowView(ingredient: $ingredient)
                }
                .onDelete(perform: viewModel.removeIngredient)

                Button {
                    showAddIngredient = true
                } label: {
                    Label("Add Ingredient", systemImage: "plus.circle")
                }
            } header: {
                Text("Ingredients (\(viewModel.ingredients.count))")
            }

            if !viewModel.skippedIngredients.isEmpty {
                Section {
                    ForEach(viewModel.skippedIngredients, id: \.self) { name in
                        Label(name, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text("Could not find nutrition data for")
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Review Ingredients")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isCalculating {
                    ProgressView()
                } else {
                    Button("Calculate") {
                        Task {
                            await viewModel.calculate(
                                using: USDANutritionRepository()
                            )
                            if viewModel.calculationResult != nil {
                                navigateToResults = true
                            }
                        }
                    }
                    .disabled(!viewModel.canCalculate)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToResults) {
            if let result = viewModel.calculationResult {
                NutritionResultsView(result: result, onSaved: onDismiss)
            }
        }
        .sheet(isPresented: $showAddIngredient) {
            AddIngredientSheet { ingredient in
                viewModel.addIngredient(ingredient)
                showAddIngredient = false
            }
        }
    }
}

// MARK: - Add Ingredient Sheet

private struct AddIngredientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var quantity: Double = 100
    @State private var unit: IngredientUnit = .grams
    let onAdd: (IngredientDraft) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Ingredient name", text: $name)

                HStack {
                    TextField("Quantity", value: $quantity, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)

                    Picker("Unit", selection: $unit) {
                        ForEach(IngredientUnit.allCases) { u in
                            Text(u.displayName).tag(u)
                        }
                    }
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(IngredientDraft(name: name, quantity: quantity, unit: unit))
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
