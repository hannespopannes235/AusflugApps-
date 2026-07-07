import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Environment(\.modelContext) private var context
    @State private var showResetConfirm = false

    var body: some View {
        List {
            datenSection
            syncSection
            aboutSection
            developerSection
        }
        .navigationTitle("Einstellungen")
        .confirmationDialog(
            "Lernfortschritt zurücksetzen?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Zurücksetzen", role: .destructive) {
                viewModel.resetLearningProgress(context: context)
            }
        } message: {
            Text("Alle Streak-Daten und Spaced-Repetition-Intervalle werden gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }

    // MARK: – Sektionen

    private var datenSection: some View {
        Section("Daten") {
            LabeledContent("Seed-Version") {
                Text(viewModel.seedVersion > 0 ? "v\(viewModel.seedVersion)" : "–")
                    .foregroundStyle(.secondary)
            }
            LabeledContent("Flugzeuge") {
                AircraftCountLabel()
            }
        }
    }

    private var syncSection: some View {
        Section {
            Toggle(isOn: Binding(
                get:  { viewModel.iCloudSyncEnabled },
                set:  { viewModel.iCloudSyncEnabled = $0 }
            )) {
                Label("iCloud-Sync", systemImage: "icloud")
            }
            .tint(DS.Color.aviationBlue)
        } header: {
            Text("Synchronisation")
        } footer: {
            Text("Favoriten und Lernfortschritt werden über iCloud auf deinen Geräten geteilt. Erfordert die iCloud-Capability im App-Target sowie einen angemeldeten iCloud-Account. Wird nach einem Neustart der App aktiv.")
                .font(.caption)
        }
    }

    private var aboutSection: some View {
        Section("Über SpotterDex") {
            LabeledContent("Version", value: viewModel.appVersion)
            LabeledContent("Entwickler", value: "Marcel Seltmann")
            LabeledContent("Datenschutz") {
                Text("Vollständig offline · Keine Tracker")
                    .foregroundStyle(.secondary)
            }
            NavigationLink("Lizenzen") {
                LicensesView()
            }
        }
    }

    private var developerSection: some View {
        Section {
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Lernfortschritt zurücksetzen", systemImage: "arrow.counterclockwise")
            }
        } header: {
            Text("Entwickler")
        } footer: {
            Text("Setzt alle Spaced-Repetition-Daten und Streaks zurück. Die Flugzeug-Datenbank bleibt erhalten.")
                .font(.caption)
        }
    }
}

// MARK: – Hilfsdaten

private struct AircraftCountLabel: View {
    @Query private var all: [Aircraft]
    var body: some View {
        Text("\(all.count) Typen")
            .foregroundStyle(.secondary)
    }
}

// MARK: – Lizenzen

private struct LicensesView: View {
    var body: some View {
        List {
            Section("Frameworks") {
                licenseRow(name: "SwiftUI", license: "Apple Inc. — Proprietär")
                licenseRow(name: "SwiftData", license: "Apple Inc. — Proprietär")
                licenseRow(name: "Core ML / Vision", license: "Apple Inc. — Proprietär")
            }
            Section("Daten") {
                licenseRow(name: "Flugzeugdaten", license: "Zusammengestellt aus öffentlichen Quellen (ICAO, Hersteller-Datenblätter)")
                licenseRow(name: "Silhouetten", license: "Eigene Canvas-Zeichnungen — CC0")
            }
            Section("Sonstiges") {
                licenseRow(name: "SM-2 Algorithmus", license: "Piotr Woźniak — gemeinfrei / open source")
            }
        }
        .navigationTitle("Lizenzen")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func licenseRow(name: String, license: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(name).font(.subheadline.bold())
            Text(license).font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [Aircraft.self, LearningRecord.self], inMemory: true)
}
