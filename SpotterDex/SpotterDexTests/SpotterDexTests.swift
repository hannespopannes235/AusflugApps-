import XCTest
@testable import SpotterDex

final class SpotterDexTests: XCTestCase {

    func testPlaceholderAlwaysPasses() throws {
        XCTAssertTrue(true, "Test-Gerüst ist einsatzbereit.")
    }

    func testStringConcatenation() throws {
        XCTAssertEqual("Spotter" + "Dex", "SpotterDex")
    }

    // MARK: – Aircraft-Modell (Phase 1)

    func testAircraftDefaultValues() throws {
        let a = Aircraft(manufacturer: "Boeing", family: "737", variant: "737-800",
                         icaoCode: "B738", iataCode: "738")
        XCTAssertEqual(a.manufacturer, "Boeing")
        XCTAssertEqual(a.icaoCode, "B738")
        XCTAssertEqual(a.engineCount, 2)
        XCTAssertEqual(a.engineType, .turbofan)
        XCTAssertEqual(a.status, .inProduction)
        XCTAssertTrue(a.visualFeatures.isEmpty)
        XCTAssertTrue(a.lookalikes.isEmpty)
    }

    func testAircraftStatusRawValues() throws {
        XCTAssertEqual(AircraftStatus.inProduction.rawValue,    "In Produktion")
        XCTAssertEqual(AircraftStatus.outOfProduction.rawValue, "Außer Produktion")
        XCTAssertEqual(AircraftStatus.retired.rawValue,         "Ausgemustert")
        XCTAssertEqual(AircraftStatus.prototype.rawValue,       "Prototyp")
    }

    func testEngineTypeRawValues() throws {
        XCTAssertEqual(EngineType.turbofan.rawValue,   "Turbofan")
        XCTAssertEqual(EngineType.turboprop.rawValue,  "Turboprop")
        XCTAssertEqual(EngineType.piston.rawValue,     "Kolben")
        XCTAssertEqual(EngineType.turboshaft.rawValue, "Turboshaft")
    }
}
