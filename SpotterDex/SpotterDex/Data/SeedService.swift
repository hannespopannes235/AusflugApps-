import Foundation
import SwiftData

// MARK: – Datenstrategie
//
// Datenquelle: kuratiertes, versioniertes JSON-Bundle-Seed.
// Quellen:     Wikidata (CC0), Jane's All the World's Aircraft,
//              Herstellerdatenblätter (öffentlich). Maße in SI.
// Versionierung: `version`-Int im JSON → UserDefaults-Schlüssel.
//              Erhöhung = erneuter Import beim nächsten Start.
//              Geplante Phase 3+: Migration via MigrationStage.
// Offline-first: Nach Erstseed kein Netz nötig.
// Bildrechte:  `imageCredits` je Datensatz Pflicht, Bilder kommen in Phase 4.

struct SeedService {
    private static let seedVersionKey = "com.spotterdex.seedVersion"
    static let currentSeedVersion = 3

    static func seedIfNeeded(modelContext: ModelContext) throws {
        let stored = UserDefaults.standard.integer(forKey: seedVersionKey)
        guard stored < currentSeedVersion else { return }

        guard
            let url = Bundle.main.url(forResource: "aircraft_seed_v1", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else { return }   // fehlendes Bundle-JSON → stille leere DB, kein Absturz

        let seed = try JSONDecoder().decode(AircraftSeed.self, from: data)

        // Idempotent per ICAO-Code:
        //   - Neue Typen werden eingefügt.
        //   - Bestehende Typen werden feldweise AKTUALISIERT, damit
        //     Datenkorrekturen (z. B. falsche Lookalike-Codes) auch
        //     Bestandsinstallationen erreichen. Nutzerdaten (isFavorite)
        //     bleiben dabei unangetastet.
        let existing = Dictionary(
            try modelContext.fetch(FetchDescriptor<Aircraft>()).map { ($0.icaoCode, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        for dto in seed.aircraft {
            if let current = existing[dto.icaoCode] {
                dto.update(current)
            } else {
                modelContext.insert(dto.toAircraft)
            }
        }

        try modelContext.save()
        UserDefaults.standard.set(currentSeedVersion, forKey: seedVersionKey)
    }

    // MARK: – Datenmigration Lernfortschritt

    private static let learnMigrationKey = "com.spotterdex.learnModeMigration"

    /// Einmalige Migration der `LearningRecord.mode`-Schlüssel:
    /// Früher wurden UI-Anzeigenamen persistiert ("Foto", "Specs",
    /// "Verwechslung", "Silhouette"); seit der Umstellung auf stabile
    /// technische Keys ("photo", "specs", "spotDiff") müssen Alt-Records
    /// umgemappt werden. Records des entfernten Silhouetten-Quiz werden
    /// gelöscht, da es den Modus nicht mehr gibt.
    static func migrateLearningRecordsIfNeeded(modelContext: ModelContext) throws {
        guard UserDefaults.standard.integer(forKey: learnMigrationKey) < 1 else { return }

        let legacyMap = [
            "Foto":         "photo",
            "Specs":        "specs",
            "Verwechslung": "spotDiff",
        ]
        let records = try modelContext.fetch(FetchDescriptor<LearningRecord>())
        for record in records {
            if let newKey = legacyMap[record.mode] {
                record.mode = newKey
            } else if record.mode == "Silhouette" {
                modelContext.delete(record)
            }
        }

        try modelContext.save()
        UserDefaults.standard.set(1, forKey: learnMigrationKey)
    }
}

// MARK: – JSON-DTOs (privat, nur für Seed-Import)

private struct AircraftSeed: Decodable {
    let version: Int
    let aircraft: [AircraftDTO]
}

private struct AircraftDTO: Decodable {
    let manufacturer: String
    let family: String
    let variant: String
    let icaoCode: String
    let iataCode: String
    let firstFlightYear: Int?
    let status: String
    let wingspan: Double
    let length: Double
    let height: Double
    let mtow: Double
    let range: Double
    let cruiseSpeed: Double
    let passengerCapacity: Int
    let engineType: String
    let engineCount: Int
    let visualFeatures: [String]
    let lookalikes: [String]
    let imageCredits: String?

    /// Überträgt alle kuratierten Felder auf einen bestehenden Datensatz.
    /// Nutzerfelder (isFavorite) werden bewusst NICHT angefasst.
    func update(_ aircraft: Aircraft) {
        aircraft.manufacturer      = manufacturer
        aircraft.family            = family
        aircraft.variant           = variant
        aircraft.iataCode          = iataCode
        aircraft.firstFlightDate   = firstFlightYear.flatMap {
            Calendar.current.date(from: DateComponents(year: $0, month: 1, day: 1))
        }
        aircraft.status            = statusMap[status] ?? .inProduction
        aircraft.wingspan          = wingspan
        aircraft.length            = length
        aircraft.height            = height
        aircraft.mtow              = mtow
        aircraft.range             = range
        aircraft.cruiseSpeed       = cruiseSpeed
        aircraft.passengerCapacity = passengerCapacity
        aircraft.engineType        = engineTypeMap[engineType] ?? .turbofan
        aircraft.engineCount       = engineCount
        aircraft.visualFeatures    = visualFeatures
        aircraft.lookalikes        = lookalikes
        aircraft.imageLicense      = imageCredits
    }

    var toAircraft: Aircraft {
        Aircraft(
            manufacturer: manufacturer,
            family: family,
            variant: variant,
            icaoCode: icaoCode,
            iataCode: iataCode,
            firstFlightDate: firstFlightYear.flatMap {
                Calendar.current.date(from: DateComponents(year: $0, month: 1, day: 1))
            },
            status: statusMap[status] ?? .inProduction,
            wingspan: wingspan,
            length: length,
            height: height,
            mtow: mtow,
            range: range,
            cruiseSpeed: cruiseSpeed,
            passengerCapacity: passengerCapacity,
            engineType: engineTypeMap[engineType] ?? .turbofan,
            engineCount: engineCount,
            visualFeatures: visualFeatures,
            lookalikes: lookalikes,
            imageURL: nil,
            imageLicense: imageCredits
        )
    }
}

// Mapping JSON-Schlüssel (englisch) → Enum (verhindert Sonderzeichen im JSON)
private let statusMap: [String: AircraftStatus] = [
    "inProduction":    .inProduction,
    "outOfProduction": .outOfProduction,
    "retired":         .retired,
    "prototype":       .prototype
]

private let engineTypeMap: [String: EngineType] = [
    "turbofan":   .turbofan,
    "turboprop":  .turboprop,
    "piston":     .piston,
    "turboshaft": .turboshaft,
    "electric":   .electric,
    "hybrid":     .hybrid
]
