import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        TabView {
            CaptureView()
                .tabItem {
                    Label("Capture", systemImage: "camera.fill")
                }

            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }

            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
        }
    }
}
