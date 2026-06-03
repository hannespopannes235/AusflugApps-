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
        XCTAssertFalse(a.isFavorite)
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

    // MARK: – AircraftEra (Phase 2)

    func testAircraftEraComputed() throws {
        let jet = Aircraft(manufacturer: "Airbus", family: "A320", variant: "A320neo",
                           icaoCode: "A20N", iataCode: "32N")
        // firstFlight default is nil → era is determined by status/type; just check non-crash
        let _ = AircraftEra.era(for: jet)
    }

    // MARK: – ClassificationResult (Phase 5 / 6)

    func testClassificationConfidenceLevel() throws {
        let high   = makeResult(confidence: 0.85)
        let medium = makeResult(confidence: 0.55)
        let low    = makeResult(confidence: 0.20)
        XCTAssertEqual(high.level,   .high)
        XCTAssertEqual(medium.level, .medium)
        XCTAssertEqual(low.level,    .low)
    }

    func testClassificationBoundaries() throws {
        let exactHigh   = makeResult(confidence: 0.70)
        let justBelow   = makeResult(confidence: 0.699)
        let exactMedium = makeResult(confidence: 0.40)
        let justBelow40 = makeResult(confidence: 0.399)
        XCTAssertEqual(exactHigh.level,   .high)
        XCTAssertEqual(justBelow.level,   .medium)
        XCTAssertEqual(exactMedium.level, .medium)
        XCTAssertEqual(justBelow40.level, .low)
    }

    func testClassificationDisplayName() throws {
        let withAircraft = ClassificationResult(
            aircraft: Aircraft(manufacturer: "Boeing", family: "737", variant: "737 MAX 8",
                               icaoCode: "B38M", iataCode: "7M8"),
            icaoLabel: "B38M",
            confidence: 0.9
        )
        let withoutAircraft = ClassificationResult(aircraft: nil, icaoLabel: "UNKN", confidence: 0.5)
        XCTAssertEqual(withAircraft.displayName,    "737 MAX 8")
        XCTAssertEqual(withoutAircraft.displayName, "UNKN")
    }

    func testConfidencePercent() throws {
        let r = makeResult(confidence: 0.756)
        XCTAssertEqual(r.confidencePercent, 75)
    }

    // MARK: – SM-2 Spaced Repetition (Phase 4)

    func testSM2FirstCorrectAnswer() throws {
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "silhouette")
        rec.recordAnswer(correct: true)
        XCTAssertEqual(rec.repetitions, 1)
        XCTAssertEqual(rec.interval, 1)
        XCTAssertEqual(rec.totalCorrect, 1)
        XCTAssertEqual(rec.totalAttempts, 1)
        XCTAssertEqual(rec.streak, 1)
    }

    func testSM2SecondCorrectAnswer() throws {
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "silhouette")
        rec.recordAnswer(correct: true)
        rec.recordAnswer(correct: true)
        XCTAssertEqual(rec.repetitions, 2)
        XCTAssertEqual(rec.interval, 6)
        XCTAssertEqual(rec.streak, 2)
    }

    func testSM2WrongAnswerResetsStreak() throws {
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "silhouette")
        rec.recordAnswer(correct: true)
        rec.recordAnswer(correct: true)
        rec.recordAnswer(correct: false)
        XCTAssertEqual(rec.streak, 0)
        XCTAssertEqual(rec.repetitions, 0)
        XCTAssertEqual(rec.interval, 1)
    }

    func testSM2AccuracyCalculation() throws {
        let rec = LearningRecord(aircraftICAO: "B738", mode: "specs")
        rec.recordAnswer(correct: true)
        rec.recordAnswer(correct: true)
        rec.recordAnswer(correct: false)
        // 2 correct out of 3 → 0.666…
        XCTAssertEqual(rec.accuracy, 2.0 / 3.0, accuracy: 0.001)
    }

    func testSM2ZeroAttemptsAccuracy() throws {
        let rec = LearningRecord(aircraftICAO: "B738", mode: "specs")
        XCTAssertEqual(rec.accuracy, 0.0)
    }

    func testSM2EaseFactorFloor() throws {
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "silhouette")
        // Repeatedly answer wrong to drive EF toward floor
        for _ in 0..<20 { rec.recordAnswer(correct: false) }
        XCTAssertGreaterThanOrEqual(rec.easeFactor, 1.3)
    }

    func testSM2IsDue() throws {
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "silhouette")
        // Fresh record: nextReview = .now → isDue
        XCTAssertTrue(rec.isDue)
    }

    // MARK: – Helpers

    private func makeResult(confidence: Float) -> ClassificationResult {
        ClassificationResult(aircraft: nil, icaoLabel: "TEST", confidence: confidence)
    }
}
