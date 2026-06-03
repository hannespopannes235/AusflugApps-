import XCTest
@testable import SpotterDex

final class SpotterDexTests: XCTestCase {

    // Phase 0: Dummy-Test – bestätigt, dass das Test-Gerüst funktioniert.
    func testPlaceholderAlwaysPasses() throws {
        XCTAssertTrue(true, "Test-Gerüst ist einsatzbereit.")
    }

    // Basis-Sanity: Swift-Standardbibliothek verfügbar
    func testStringConcatenation() throws {
        let result = "Spotter" + "Dex"
        XCTAssertEqual(result, "SpotterDex")
    }
}
