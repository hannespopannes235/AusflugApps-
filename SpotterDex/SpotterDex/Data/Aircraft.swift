import Foundation
import SwiftData

/// Produktions-/Betriebsstatus eines Flugzeugtyps.
enum AircraftStatus: String, Codable, CaseIterable, Sendable {
    case inProduction    = "In Produktion"
    case outOfProduction = "Außer Produktion"
    case retired         = "Ausgemustert"
    case prototype       = "Prototyp"
}

/// Primäre Antriebstechnologie.
enum EngineType: String, Codable, CaseIterable, Sendable {
    case turbofan   = "Turbofan"
    case turboprop  = "Turboprop"
    case piston     = "Kolben"
    case turboshaft = "Turboshaft"
    case electric   = "Elektrisch"
    case hybrid     = "Hybrid"
}

/// Kern-Domänenentität – repräsentiert einen Flugzeugtyp/eine Variante.
/// Alle Maße in SI-Einheiten (m, kg, km, km/h).
/// Alle Attribute haben Defaults → CloudKit-kompatibel (Voraussetzung
/// für den optionalen iCloud-Sync).
@Model
final class Aircraft {

    // MARK: – Identifikation
    var manufacturer: String = ""   // Hersteller, z. B. "Boeing"
    var family: String = ""         // Familie, z. B. "737"
    var variant: String = ""        // Variante, z. B. "737-800"
    var icaoCode: String = ""       // ICAO-Typencode, z. B. "B738"
    var iataCode: String = ""       // IATA-Code, z. B. "738"

    // MARK: – Geschichte
    var firstFlightDate: Date?      // Erstflug
    var status: AircraftStatus = .inProduction   // Produktionsstatus

    // MARK: – Abmessungen
    var wingspan: Double = 0        // Spannweite in m
    var length: Double = 0          // Länge in m
    var height: Double = 0          // Höhe in m

    // MARK: – Leistung
    var mtow: Double = 0            // Max. Abflugmasse in kg
    var range: Double = 0           // Reichweite in km
    var cruiseSpeed: Double = 0     // Reisegeschwindigkeit in km/h

    // MARK: – Kapazität & Antrieb
    var passengerCapacity: Int = 0  // Pax-Kapazität (konfigurationsabhängig; typische Maximalbestuhlung)
    var engineType: EngineType = .turbofan   // Triebwerk-Typ
    var engineCount: Int = 2        // Anzahl Triebwerke

    // MARK: – Visuelles Erkennungswissen
    var visualFeatures: [String] = []   // Erkennungsmerkmale (Freitext)
    var lookalikes: [String] = []       // Verwechslungspartner (ICAO-Codes)

    // MARK: – Medien
    var imageURL: String?           // Asset-Name oder Remote-URL
    var imageLicense: String?       // Pflichtangabe: Lizenz/Urheber

    // MARK: – Nutzerdaten
    var isFavorite: Bool = false

    init(
        manufacturer: String,
        family: String,
        variant: String,
        icaoCode: String = "",
        iataCode: String = "",
        firstFlightDate: Date? = nil,
        status: AircraftStatus = .inProduction,
        wingspan: Double = 0,
        length: Double = 0,
        height: Double = 0,
        mtow: Double = 0,
        range: Double = 0,
        cruiseSpeed: Double = 0,
        passengerCapacity: Int = 0,
        engineType: EngineType = .turbofan,
        engineCount: Int = 2,
        visualFeatures: [String] = [],
        lookalikes: [String] = [],
        imageURL: String? = nil,
        imageLicense: String? = nil,
        isFavorite: Bool = false
    ) {
        self.manufacturer = manufacturer
        self.family = family
        self.variant = variant
        self.icaoCode = icaoCode
        self.iataCode = iataCode
        self.firstFlightDate = firstFlightDate
        self.status = status
        self.wingspan = wingspan
        self.length = length
        self.height = height
        self.mtow = mtow
        self.range = range
        self.cruiseSpeed = cruiseSpeed
        self.passengerCapacity = passengerCapacity
        self.engineType = engineType
        self.engineCount = engineCount
        self.visualFeatures = visualFeatures
        self.lookalikes = lookalikes
        self.imageURL = imageURL
        self.imageLicense = imageLicense
        self.isFavorite = isFavorite
    }
}
