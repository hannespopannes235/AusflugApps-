import Foundation

/// UI-seitige Filter-Kategorie nach Erstflug-Jahr.
enum AircraftEra: String, CaseIterable, Identifiable {
    case classic  = "Klassiker (vor 1980)"
    case eighties = "Achtziger (1980–1989)"
    case nineties = "Neunziger (1990–1999)"
    case modern   = "Modern (2000–2014)"
    case newGen   = "Neue Generation (2015+)"

    var id: String { rawValue }

    /// `true` wenn das Erstflugdatum in diese Ära fällt.
    func matches(_ date: Date?) -> Bool {
        guard let date else { return false }
        let year = Calendar.current.component(.year, from: date)
        switch self {
        case .classic:  return year < 1980
        case .eighties: return (1980..<1990).contains(year)
        case .nineties: return (1990..<2000).contains(year)
        case .modern:   return (2000..<2015).contains(year)
        case .newGen:   return year >= 2015
        }
    }
}
