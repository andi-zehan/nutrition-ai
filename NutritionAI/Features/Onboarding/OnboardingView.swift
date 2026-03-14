import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var showBodyMetrics = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)

                VStack(spacing: 12) {
                    Text("NutritionAI")
                        .font(.largeTitle.bold())

                    Text("Log meals with AI-powered ingredient detection, then review and calculate nutrition from real data.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        showBodyMetrics = true
                    } label: {
                        Text("Set Up Body Metrics")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        environment.hasCompletedOnboarding = true
                    } label: {
                        Text("Skip for Now")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationDestination(isPresented: $showBodyMetrics) {
                BodyMetricsView(isOnboarding: true)
            }
        }
    }
}
