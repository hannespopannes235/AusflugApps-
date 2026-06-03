import SwiftUI
import SwiftData

@main
struct SpotterDexApp: App {
    let container: ModelContainer

    init() {
        do {
            // Für iCloud-Sync: ModelConfiguration(cloudKitDatabase: .automatic) +
            // iCloud-Capability im Xcode-Target aktivieren.
            container = try ModelContainer(for: Aircraft.self, LearningRecord.self)
            // Seed beim ersten Start – synchron auf mainContext, vor UI-Aufbau.
            try SeedService.seedIfNeeded(modelContext: container.mainContext)
        } catch {
            fatalError("SwiftData-Fehler beim Start: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
