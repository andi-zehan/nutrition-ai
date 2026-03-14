import Charts
import SwiftUI

struct GoalsView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var selectedRange: TrendRange = .today

    var body: some View {
        NavigationStack {
            Group {
                if let metrics = environment.bodyMetrics {
                    goalsContent(metrics: metrics)
                } else {
                    incompleteState
                }
            }
            .navigationTitle("Goals")
        }
    }

    private func goalsContent(metrics: BodyMetrics) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Range picker
                Picker("Range", selection: $selectedRange) {
                    ForEach(TrendRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                let snapshot = environment.mealHistoryStore.snapshot(for: selectedRange)
                let dailyGoal = metrics.dailyCalorieGoal

                // Calorie progress
                calorieProgressCard(
                    intake: snapshot.totalNutrition.calories,
                    goal: dailyGoal * Double(max(snapshot.activeDays, 1))
                )

                // Calorie trend chart (only for 7/30 day ranges)
                if selectedRange != .today {
                    calorieTrendChart(dailyGoal: dailyGoal)
                }

                // Macro breakdown
                macroCard(snapshot: snapshot)

                // Macro trend chart (only for 7/30 day ranges)
                if selectedRange != .today {
                    macroTrendChart
                }

                // Summary
                summaryCard(snapshot: snapshot)
            }
            .padding(.vertical)
        }
    }

    // MARK: - Calorie Progress

    private func calorieProgressCard(intake: Double, goal: Double) -> some View {
        VStack(spacing: 12) {
            Text("Calories")
                .font(.headline)

            let progress = CalorieGoalCalculator.normalizedProgress(intake: intake, goal: goal)

            ProgressView(value: progress)
                .tint(progressColor(for: progress))

            HStack {
                Text("\(Int(intake)) kcal")
                    .font(.title2.bold())
                Spacer()
                let remaining = CalorieGoalCalculator.remaining(intake: intake, goal: goal)
                if remaining >= 0 {
                    Text("\(Int(remaining)) remaining")
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(Int(-remaining)) over")
                        .foregroundStyle(.red)
                }
            }

            Text("Goal: \(Int(goal)) kcal")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Calorie Trend Chart

    private func calorieTrendChart(dailyGoal: Double) -> some View {
        let entries = dailyCalorieEntries

        return VStack(alignment: .leading, spacing: 8) {
            Text("Calorie Trend")
                .font(.headline)

            Chart {
                ForEach(entries, id: \.date) { entry in
                    BarMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Calories", entry.calories)
                    )
                    .foregroundStyle(entry.calories > dailyGoal ? .red : .blue)
                    .cornerRadius(4)
                }

                RuleMark(y: .value("Goal", dailyGoal))
                    .lineStyle(.init(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.green)
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Goal")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 160)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Macro Card

    private func macroCard(snapshot: TrendSnapshot) -> some View {
        VStack(spacing: 12) {
            Text("Macros")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                macroItem("Protein", grams: snapshot.totalNutrition.proteinGrams, percent: snapshot.proteinPercent, color: .orange)
                macroItem("Carbs", grams: snapshot.totalNutrition.carbsGrams, percent: snapshot.carbsPercent, color: .blue)
                macroItem("Fat", grams: snapshot.totalNutrition.fatGrams, percent: snapshot.fatPercent, color: .red)
            }

            // Donut-style macro split
            if snapshot.totalNutrition.calories > 0 {
                macroBar(snapshot: snapshot)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func macroBar(snapshot: TrendSnapshot) -> some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                if snapshot.proteinPercent > 0 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.orange)
                        .frame(width: geo.size.width * snapshot.proteinPercent / 100)
                }
                if snapshot.carbsPercent > 0 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.blue)
                        .frame(width: geo.size.width * snapshot.carbsPercent / 100)
                }
                if snapshot.fatPercent > 0 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.red)
                        .frame(width: geo.size.width * snapshot.fatPercent / 100)
                }
            }
        }
        .frame(height: 12)
    }

    private func macroItem(_ label: String, grams: Double, percent: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(Int(grams))g")
                .font(.title3.bold())
            Text("\(Int(percent))%")
                .font(.caption2)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Macro Trend Chart

    private var macroTrendChart: some View {
        let entries = dailyMacroEntries

        return VStack(alignment: .leading, spacing: 8) {
            Text("Macro Trend")
                .font(.headline)

            Chart {
                ForEach(entries, id: \.date) { entry in
                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Grams", entry.protein),
                        series: .value("Macro", "Protein")
                    )
                    .foregroundStyle(.orange)

                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Grams", entry.carbs),
                        series: .value("Macro", "Carbs")
                    )
                    .foregroundStyle(.blue)

                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Grams", entry.fat),
                        series: .value("Macro", "Fat")
                    )
                    .foregroundStyle(.red)
                }
            }
            .chartForegroundStyleScale([
                "Protein": .orange,
                "Carbs": .blue,
                "Fat": .red
            ])
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 140)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Summary

    private func summaryCard(snapshot: TrendSnapshot) -> some View {
        VStack(spacing: 8) {
            LabeledContent("Meals logged", value: "\(snapshot.mealCount)")
            LabeledContent("Active days", value: "\(snapshot.activeDays)")
            LabeledContent("Avg daily calories", value: "\(Int(snapshot.averageDailyCalories)) kcal")
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Incomplete State

    private var incompleteState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "figure.stand")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Set up body metrics to see your calorie goal and progress.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            NavigationLink("Set Up Body Metrics") {
                BodyMetricsView(isOnboarding: false)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func progressColor(for progress: Double) -> Color {
        switch progress {
        case ..<0.35: .green
        case ..<0.70: .yellow
        case ..<0.90: .orange
        default: .red
        }
    }

    private var dailyCalorieEntries: [DailyCalorieEntry] {
        let calendar = Calendar.current
        let days = selectedRange.dayCount
        let today = calendar.startOfDay(for: Date())

        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayMeals = environment.mealHistoryStore.meals(for: date)
            let total = dayMeals.reduce(0.0) { $0 + $1.nutrition.calories }
            return DailyCalorieEntry(date: date, calories: total)
        }.reversed()
    }

    private var dailyMacroEntries: [DailyMacroEntry] {
        let calendar = Calendar.current
        let days = selectedRange.dayCount
        let today = calendar.startOfDay(for: Date())

        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayMeals = environment.mealHistoryStore.meals(for: date)
            return DailyMacroEntry(
                date: date,
                protein: dayMeals.reduce(0) { $0 + $1.nutrition.proteinGrams },
                carbs: dayMeals.reduce(0) { $0 + $1.nutrition.carbsGrams },
                fat: dayMeals.reduce(0) { $0 + $1.nutrition.fatGrams }
            )
        }.reversed()
    }
}

private struct DailyCalorieEntry {
    let date: Date
    let calories: Double
}

private struct DailyMacroEntry {
    let date: Date
    let protein: Double
    let carbs: Double
    let fat: Double
}
