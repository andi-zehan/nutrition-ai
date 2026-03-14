import SwiftUI

struct BodyMetricsView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    let isOnboarding: Bool

    @State private var weightKg: Double = 70
    @State private var heightCm: Double = 170
    @State private var age: Int = 30
    @State private var sex: BiologicalSex = .male
    @State private var activityLevel: ActivityLevel = .moderatelyActive
    @State private var weightGoal: WeightGoal = .maintain

    var body: some View {
        Form {
            Section("Body") {
                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("kg", value: $weightKg, format: .number.precision(.fractionLength(1)))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("kg")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Height")
                    Spacer()
                    TextField("cm", value: $heightCm, format: .number.precision(.fractionLength(0)))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("cm")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Age")
                    Spacer()
                    TextField("years", value: $age, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }

                Picker("Sex", selection: $sex) {
                    ForEach(BiologicalSex.allCases) { s in
                        Text(s.rawValue.capitalized).tag(s)
                    }
                }
            }

            Section("Activity") {
                Picker("Activity Level", selection: $activityLevel) {
                    ForEach(ActivityLevel.allCases) { level in
                        Text(level.displayName).tag(level)
                    }
                }
            }

            Section("Goal") {
                Picker("Weight Goal", selection: $weightGoal) {
                    ForEach(WeightGoal.allCases) { goal in
                        Text(goal.displayName).tag(goal)
                    }
                }
            }

            Section {
                let metrics = currentMetrics
                LabeledContent("BMR", value: "\(Int(metrics.bmr)) kcal")
                LabeledContent("TDEE", value: "\(Int(metrics.tdee)) kcal")
                LabeledContent("Daily Goal", value: "\(Int(metrics.dailyCalorieGoal)) kcal")
                LabeledContent("BMI", value: String(format: "%.1f", metrics.bmi))
            } header: {
                Text("Calculated")
            }
        }
        .navigationTitle("Body Metrics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveAndDismiss()
                }
            }
        }
        .onAppear {
            if let existing = environment.bodyMetrics {
                weightKg = existing.weightKg
                heightCm = existing.heightCm
                age = existing.age
                sex = existing.sex
                activityLevel = existing.activityLevel
                weightGoal = existing.weightGoal
            }
        }
    }

    private var currentMetrics: BodyMetrics {
        BodyMetrics(
            weightKg: weightKg,
            heightCm: heightCm,
            age: age,
            sex: sex,
            activityLevel: activityLevel,
            weightGoal: weightGoal
        )
    }

    private func saveAndDismiss() {
        environment.bodyMetrics = currentMetrics
        if isOnboarding {
            environment.hasCompletedOnboarding = true
        }
        dismiss()
    }
}
