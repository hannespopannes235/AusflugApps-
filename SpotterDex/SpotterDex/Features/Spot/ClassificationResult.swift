import Foundation

/// Ergebnis einer Core-ML-Klassifikation für einen Flugzeugtyp.
struct ClassificationResult: Identifiable {
    let id = UUID()
    /// Übereinstimmendes Aircraft aus der lokalen DB – nil wenn ICAO-Label unbekannt.
    let aircraft: Aircraft?
    /// Rohes Label des Modells (= ICAO-Code, z. B. "A20N").
    let icaoLabel: String
    /// Konfidenz 0…1 vom Vision-Framework.
    let confidence: Float

    var displayName: String  { aircraft?.variant ?? icaoLabel }
    var confidencePercent: Int { Int(confidence * 100) }

    var level: ConfidenceLevel {
        confidence >= 0.70 ? .high : confidence >= 0.40 ? .medium : .low
    }

    enum ConfidenceLevel {
        case high, medium, low
        var color: String { self == .high ? "green" : self == .medium ? "orange" : "red" }
    }
}
