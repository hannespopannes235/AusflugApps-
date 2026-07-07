import SwiftUI
import SwiftData

@main
struct SpotterDexApp: App {
    let container: ModelContainer

    init() {
        do {
            // iCloud-Sync laut Settings-Toggle. CloudKit setzt die iCloud-
            // Capability im Xcode-Target voraus – fehlt sie (oder ist kein
            // Account angemeldet), schlägt die Container-Erstellung fehl und
            // wir fallen sauber auf den lokalen Store zurück.
            let wantsCloud = UserDefaults.standard.bool(forKey: "com.spotterdex.iCloudSync")
            if wantsCloud,
               let cloudContainer = try? ModelContainer(
                   for: Aircraft.self, LearningRecord.self,
                   configurations: ModelConfiguration(cloudKitDatabase: .automatic)
               ) {
                container = cloudContainer
            } else {
                container = try ModelContainer(
                    for: Aircraft.self, LearningRecord.self,
                    configurations: ModelConfiguration(cloudKitDatabase: .none)
                )
            }
            // Seed & Migration beim Start – synchron auf mainContext, vor UI-Aufbau.
            try SeedService.seedIfNeeded(modelContext: container.mainContext)
            try SeedService.migrateLearningRecordsIfNeeded(modelContext: container.mainContext)
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
