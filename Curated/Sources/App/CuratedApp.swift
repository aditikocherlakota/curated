import SwiftUI

@main
struct CuratedApp: App {
    @StateObject private var vibeStore = VibeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vibeStore)
        }
    }
}
