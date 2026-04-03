import SwiftUI
import SwiftData

@main
struct EuclidApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [GameSession.self, UserSettings.self])
    }
}
