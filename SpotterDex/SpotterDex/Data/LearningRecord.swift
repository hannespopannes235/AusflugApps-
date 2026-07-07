import Foundation
import SwiftData

/// Lernfortschritt eines Flugzeugtyps in einem bestimmten Lernmodus.
/// Alle Felder haben Defaults → CloudKit-kompatibel.
/// SM-2-Algorithmus: easeFactor ≥ 1.3, Intervall wächst mit korrekten Antworten.
@Model
final class LearningRecord {
    var aircraftICAO: String = ""
    var mode: String = ""
    var easeFactor: Double = 2.5
    var interval: Int = 1
    var repetitions: Int = 0
    var nextReview: Date = Date.now
    var streak: Int = 0
    var totalCorrect: Int = 0
    var totalAttempts: Int = 0
    var lastSeen: Date?

    init(aircraftICAO: String, mode: String) {
        self.aircraftICAO = aircraftICAO
        self.mode = mode
    }

    /// Verarbeitet eine Antwort und aktualisiert nextReview nach SM-2.
    func recordAnswer(correct: Bool) {
        totalAttempts += 1
        lastSeen = .now

        if correct {
            totalCorrect += 1
            streak += 1
            // Qualität aus der Serie ableiten: Karten, die sicher sitzen
            // (Streak ≥ 3), bekommen q=5 → EaseFactor wächst und die
            // Intervalle dehnen sich schneller. Mit fixem q=4 wäre das
            // EF-Delta exakt 0 und die Formel wirkungslos.
            let quality = streak >= 3 ? 5.0 : 4.0
            easeFactor = max(1.3, easeFactor + 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
            switch repetitions {
            case 0:  interval = 1
            case 1:  interval = 6
            default: interval = Int((Double(interval) * easeFactor).rounded())
            }
            repetitions += 1
        } else {
            streak = 0
            repetitions = 0
            interval = 1
        }
        nextReview = Calendar.current.date(byAdding: .day, value: interval, to: .now) ?? .now
    }

    var accuracy: Double {
        totalAttempts > 0 ? Double(totalCorrect) / Double(totalAttempts) : 0
    }

    var isDue: Bool { nextReview <= .now }
}
