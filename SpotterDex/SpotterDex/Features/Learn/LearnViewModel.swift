import Foundation
import SwiftData
import Observation

// MARK: – Lernmodus

/// Die rawValues sind STABILE technische Schlüssel und werden in
/// `LearningRecord.mode` persistiert – niemals ändern oder lokalisieren.
/// Anzeige-Texte kommen aus `displayName`.
enum LearnMode: String, CaseIterable, Identifiable {
    case photo    = "photo"
    case specs    = "specs"
    case spotDiff = "spotDiff"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .photo:    "Foto"
        case .specs:    "Specs"
        case .spotDiff: "Verwechslung"
        }
    }

    var systemImage: String {
        switch self {
        case .photo:    "photo"
        case .specs:    "list.bullet.clipboard"
        case .spotDiff: "questionmark.diamond"
        }
    }

    var description: String {
        switch self {
        case .photo:    "Erkenne den Typ am echten Foto"
        case .specs:    "Ordne Specs dem richtigen Typ zu"
        case .spotDiff: "Unterscheide Verwechslungspartner"
        }
    }
}

// MARK: – ViewModel

@Observable
final class LearnViewModel {
    var sessionStreak:  Int = 0
    var sessionCorrect: Int = 0
    var sessionTotal:   Int = 0

    func recordAnswer(correct: Bool) {
        sessionTotal += 1
        if correct {
            sessionCorrect += 1
            sessionStreak  += 1
        } else {
            sessionStreak = 0
        }
    }

    // MARK: – Spaced-Repetition-Auswahl

    /// Nächste Karteikarte nach SM-2-Priorität:
    /// 1. Fällige Karten, nach niedrigster Accuracy sortiert
    /// 2. Noch nie gesehene Karten (kein Record → isDue = true via ?? true)
    /// 3. Zufällig
    func pickAircraft(
        from aircraft: [Aircraft],
        records: [LearningRecord],
        mode: LearnMode
    ) -> Aircraft? {
        guard !aircraft.isEmpty else { return nil }
        let modeKey = mode.rawValue
        // uniquingKeysWith statt uniqueKeysWithValues: doppelte Records pro
        // (ICAO, Modus) sind möglich (z. B. nach CloudKit-Sync) und dürfen
        // nicht crashen – der ältere Record gewinnt.
        let recordMap = Dictionary(
            records.filter { $0.mode == modeKey }.map { ($0.aircraftICAO, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        let due = aircraft.filter { recordMap[$0.icaoCode]?.isDue ?? true }
        if !due.isEmpty {
            return due.min {
                (recordMap[$0.icaoCode]?.accuracy ?? 0) < (recordMap[$1.icaoCode]?.accuracy ?? 0)
            }
        }
        return aircraft.randomElement()
    }

    /// Sucht einen vorhandenen LearningRecord oder legt einen neuen an.
    func record(
        for aircraft: Aircraft,
        mode: LearnMode,
        in records: [LearningRecord],
        context: ModelContext
    ) -> LearningRecord {
        if let existing = records.first(where: {
            $0.aircraftICAO == aircraft.icaoCode && $0.mode == mode.rawValue
        }) {
            return existing
        }
        let rec = LearningRecord(aircraftICAO: aircraft.icaoCode, mode: mode.rawValue)
        context.insert(rec)
        return rec
    }
}
