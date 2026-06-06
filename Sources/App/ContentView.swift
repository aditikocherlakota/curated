import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vibeStore: VibeStore

    var body: some View {
        TabView {
            ConversationView()
                .tabItem {
                    Label("Talk", systemImage: "waveform")
                }

            CameraView()
                .tabItem {
                    Label("Fit Check", systemImage: "camera")
                }

            RecommendationsView()
                .tabItem {
                    Label("For You", systemImage: "sparkles")
                }

            SettingsView()
                .tabItem {
                    Label("Vibe", systemImage: "person.crop.circle")
                }
        }
        .tint(DesignSystem.Colors.primary)
    }
}
