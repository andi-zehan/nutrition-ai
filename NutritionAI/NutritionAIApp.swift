import SwiftUI

@main
struct NutritionAIApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            Group {
                if environment.hasCompletedOnboarding {
                    RootTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(environment)
            .task {
                await environment.performStartupTasks()
            }
        }
    }
}
