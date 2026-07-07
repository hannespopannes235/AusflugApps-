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

// MARK: – Spec-Extraktoren (geteilt von Specs-Quiz und Verwechslungs-Quiz)

enum QuizSpec {
    /// Basis-Kennzahlen, an denen sich Typen unterscheiden lassen.
    static let base: [(label: String, value: (Aircraft) -> String)] = [
        ("Spannweite", { $0.wingspan.formatted(.number.precision(.fractionLength(1))) + " m" }),
        ("Länge",      { $0.length.formatted(.number.precision(.fractionLength(1))) + " m" }),
        ("Reichweite", { Int($0.range).formatted() + " km" }),
        ("MTOW",       { (Int($0.mtow / 1_000)).formatted() + " t" }),
        ("Passagiere", { $0.passengerCapacity.formatted() + " Pax" }),
    ]

    /// Erweiterter Satz fürs Specs-Quiz.
    static let extended = base + [
        ("Triebwerke", { (a: Aircraft) in "\(a.engineCount)× \(a.engineType.rawValue)" }),
    ]
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

    /// 4 Antwortoptionen: Ziel + bis zu 3 Distraktoren, Lookalikes bevorzugt
    /// (didaktisch wertvoller als reine Zufalls-Distraktoren).
    /// Zuvor wortgleich in PhotoQuizView und SpecsQuizView dupliziert.
    func buildChoices(for target: Aircraft, from aircraft: [Aircraft]) -> [Aircraft] {
        let lookalikes = target.lookalikes
            .compactMap { icao in aircraft.first { $0.icaoCode == icao } }
            .shuffled()
        let others = aircraft
            .filter { $0.icaoCode != target.icaoCode && !target.lookalikes.contains($0.icaoCode) }
            .shuffled()
        let distractors = Array((lookalikes + others).prefix(3))
        return ([target] + distractors).shuffled()
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
