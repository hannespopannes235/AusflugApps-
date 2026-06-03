import SwiftUI
import SwiftData

@main
struct SpotterDexApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Aircraft.self)
    }
}
