import Foundation

/// Reads developer-provided API keys from Info.plist (injected via Secrets.xcconfig).
enum AppConfig {
    static var openRouterAPIKey: String {
        Bundle.main.infoDictionary?["OPENROUTER_API_KEY"] as? String ?? ""
    }

    static var usdaAPIKey: String {
        Bundle.main.infoDictionary?["USDA_API_KEY"] as? String ?? ""
    }

    static let openRouterModel = "openai/gpt-4.1-mini"
    static let openRouterBaseURL = URL(string: "https://openrouter.ai/api/v1")!
    static let usdaBaseURL = URL(string: "https://api.nal.usda.gov/fdc/v1")!

    static let photoRetentionDays = 30
    static let mealRetentionDays = 365
}
