import SwiftUI
import SwiftData

@Observable final class SettingsViewModel {

    // MARK: – Persistenz

    private let defaults = UserDefaults.standard

    var iCloudSyncEnabled: Bool {
        get { defaults.bool(forKey: "com.spotterdex.iCloudSync") }
        set { defaults.set(newValue, forKey: "com.spotterdex.iCloudSync") }
    }

    // MARK: – App-Infos (read-only)

    var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var seedVersion: Int {
        defaults.integer(forKey: "com.spotterdex.seedVersion")
    }

    // MARK: – Aktionen

    func resetLearningProgress(context: ModelContext) {
        do {
            try context.delete(model: LearningRecord.self)
            try context.save()
        } catch {
            // best-effort; SwiftData propagates errors through the context
        }
    }
}
