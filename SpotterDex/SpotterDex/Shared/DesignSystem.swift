import SwiftUI

/// Zentrales Design-System für SpotterDex.
/// Outdoor-optimiert: hohe Sättigungswerte für Sonnenlicht-Lesbarkeit,
/// klare Kontraste für die Flugzeugbeobachter-Praxis.
enum DS {

    // MARK: – Farben

    enum Color {
        /// Aviationsblau – Primär-Akzent (ICAO-Codes, Links)
        static let aviationBlue  = SwiftUI.Color(red: 0.00, green: 0.47, blue: 0.80)
        /// Amber – Warnungen, mittlere Konfidenz
        static let amber         = SwiftUI.Color(red: 1.00, green: 0.62, blue: 0.00)
        /// Runway-Grün – Erfolg, hohe Konfidenz, Favorit
        static let runwayGreen   = SwiftUI.Color(red: 0.07, green: 0.65, blue: 0.26)
        /// Alert-Rot – Fehler, niedrige Konfidenz
        static let alertRed      = SwiftUI.Color(red: 0.90, green: 0.10, blue: 0.05)
        /// Cockpit-Grau – sekundäre Elemente, Beschriftungen
        static let cockpitGray   = SwiftUI.Color(red: 0.30, green: 0.32, blue: 0.35)
    }

    // MARK: – Abstände

    enum Spacing {
        static let xs: CGFloat = 4
        static let s:  CGFloat = 8
        static let m:  CGFloat = 16
        static let l:  CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: – Eckenradien

    enum Radius {
        static let card:   CGFloat = 14
        static let button: CGFloat = 10
        static let badge:  CGFloat = 6
    }

    // MARK: – Typografie-Hilfsmethoden

    /// Monospaced-Digit-Stil für Zahlenwerte (Specs, Konfidenz).
    static func specFont(size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}
