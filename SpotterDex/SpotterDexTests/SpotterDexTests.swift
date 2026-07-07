import XCTest
@testable import SpotterDex

final class SpotterDexTests: XCTestCase {

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

    func testAircraftEraMatches() throws {
        func date(year: Int) -> Date {
            Calendar.current.date(from: DateComponents(year: year, month: 6, day: 1))!
        }
        XCTAssertTrue(AircraftEra.classic.matches(date(year: 1969)))
        XCTAssertTrue(AircraftEra.eighties.matches(date(year: 1986)))
        XCTAssertTrue(AircraftEra.nineties.matches(date(year: 1998)))
        XCTAssertTrue(AircraftEra.modern.matches(date(year: 2005)))
        XCTAssertTrue(AircraftEra.newGen.matches(date(year: 2016)))
        // Grenzen: 1980 gehört zu den Achtzigern, nicht zu den Klassikern
        XCTAssertFalse(AircraftEra.classic.matches(date(year: 1980)))
        XCTAssertTrue(AircraftEra.eighties.matches(date(year: 1980)))
        // Ohne Erstflugdatum passt keine Ära
        for era in AircraftEra.allCases {
            XCTAssertFalse(era.matches(nil))
        }
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
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "photo")
        rec.recordAnswer(correct: true)
        XCTAssertEqual(rec.repetitions, 1)
        XCTAssertEqual(rec.interval, 1)
        XCTAssertEqual(rec.totalCorrect, 1)
        XCTAssertEqual(rec.totalAttempts, 1)
        XCTAssertEqual(rec.streak, 1)
    }

    func testSM2SecondCorrectAnswer() throws {
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "photo")
        rec.recordAnswer(correct: true)
        rec.recordAnswer(correct: true)
        XCTAssertEqual(rec.repetitions, 2)
        XCTAssertEqual(rec.interval, 6)
        XCTAssertEqual(rec.streak, 2)
    }

    func testSM2WrongAnswerResetsStreak() throws {
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "photo")
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
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "photo")
        // Repeatedly answer wrong to drive EF toward floor
        for _ in 0..<20 { rec.recordAnswer(correct: false) }
        XCTAssertGreaterThanOrEqual(rec.easeFactor, 1.3)
    }

    func testSM2IsDue() throws {
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "photo")
        // Fresh record: nextReview = .now → isDue
        XCTAssertTrue(rec.isDue)
    }

    func testSM2EaseFactorGrowsWithStreak() throws {
        // Ab Streak ≥ 3 gilt Qualität 5 → EaseFactor wächst über den Startwert.
        let rec = LearningRecord(aircraftICAO: "A20N", mode: "photo")
        XCTAssertEqual(rec.easeFactor, 2.5, accuracy: 0.001)
        for _ in 0..<5 { rec.recordAnswer(correct: true) }
        XCTAssertGreaterThan(rec.easeFactor, 2.5)
    }

    // MARK: – Seed-Datenqualität (Phase E)
    // Diese Tests hätten die Lookalike-Datenfehler gefangen, die in Phase A
    // manuell korrigiert wurden (Klarnamen statt ICAO-Codes im Seed).

    private func loadSeedAircraft() throws -> [[String: Any]] {
        let bundle = Bundle(for: LearningRecord.self)   // App-Bundle, nicht Test-Bundle
        let url = try XCTUnwrap(bundle.url(forResource: "aircraft_seed_v1", withExtension: "json"),
                                "aircraft_seed_v1.json fehlt im App-Bundle")
        let json = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        )
        return try XCTUnwrap(json["aircraft"] as? [[String: Any]])
    }

    func testSeedHasExpectedTypeCount() throws {
        XCTAssertEqual(try loadSeedAircraft().count, 18)
    }

    func testSeedICAOCodesAreUnique() throws {
        let codes = try loadSeedAircraft().compactMap { $0["icaoCode"] as? String }
        XCTAssertEqual(codes.count, Set(codes).count, "Doppelte ICAO-Codes im Seed")
    }

    func testSeedLookalikesAreValidICAOCodes() throws {
        // Lookalikes müssen ICAO-Typencodes sein (3–4 Zeichen, Großbuchstaben/
        // Ziffern) – keine Klarnamen wie "A321neo" oder "B737 MAX 8".
        for entry in try loadSeedAircraft() {
            let icao = entry["icaoCode"] as? String ?? "?"
            for lookalike in entry["lookalikes"] as? [String] ?? [] {
                XCTAssertTrue(
                    (3...4).contains(lookalike.count)
                        && lookalike.allSatisfy { $0.isUppercase || $0.isNumber },
                    "\(icao): Lookalike '\(lookalike)' ist kein ICAO-Code"
                )
                XCTAssertNotEqual(lookalike, icao, "\(icao) listet sich selbst als Lookalike")
            }
        }
    }

    func testSeedEveryTypeHasWikimediaPhoto() throws {
        for entry in try loadSeedAircraft() {
            let icao = try XCTUnwrap(entry["icaoCode"] as? String)
            XCTAssertNotNil(WikimediaPhotoService.imageURL(for: icao),
                            "\(icao) hat kein Commons-Foto-Mapping")
        }
    }

    // MARK: – LearnViewModel (Phase E)

    func testBuildChoicesReturnsFourUniqueIncludingTarget() throws {
        let fleet = (0..<8).map { i in
            Aircraft(manufacturer: "M", family: "F", variant: "V\(i)", icaoCode: "T\(i)0\(i)")
        }
        let target = fleet[0]
        let choices = LearnViewModel().buildChoices(for: target, from: fleet)
        XCTAssertEqual(choices.count, 4)
        XCTAssertEqual(Set(choices.map(\.icaoCode)).count, 4, "Optionen müssen eindeutig sein")
        XCTAssertTrue(choices.contains { $0.icaoCode == target.icaoCode })
    }

    func testBuildChoicesPrefersLookalikes() throws {
        let target = Aircraft(manufacturer: "Airbus", family: "A320", variant: "A320neo",
                              icaoCode: "A20N", lookalikes: ["B738", "A21N", "B38M"])
        let fleet = [target] + ["B738", "A21N", "B38M", "A388", "AT76"].map {
            Aircraft(manufacturer: "M", family: "F", variant: $0, icaoCode: $0)
        }
        let choices = LearnViewModel().buildChoices(for: target, from: fleet)
        // Alle 3 Distraktoren müssen aus den Lookalikes stammen
        let distractors = Set(choices.map(\.icaoCode)).subtracting(["A20N"])
        XCTAssertTrue(distractors.isSubset(of: ["B738", "A21N", "B38M"]))
    }

    func testPickAircraftPrefersUnseenAndDue() throws {
        let vm = LearnViewModel()
        let a = Aircraft(manufacturer: "M", family: "F", variant: "A", icaoCode: "AAAA")
        let b = Aircraft(manufacturer: "M", family: "F", variant: "B", icaoCode: "BBBB")
        // A wurde gerade richtig beantwortet (nextReview in der Zukunft),
        // B ist ungesehen → B muss gewählt werden.
        let recA = LearningRecord(aircraftICAO: "AAAA", mode: "photo")
        recA.recordAnswer(correct: true)
        let picked = vm.pickAircraft(from: [a, b], records: [recA], mode: .photo)
        XCTAssertEqual(picked?.icaoCode, "BBBB")
    }

    func testPickAircraftSurvivesDuplicateRecords() throws {
        // Doppelte (ICAO, Modus)-Records (z. B. nach CloudKit-Sync) dürfen
        // nicht crashen (früher: Dictionary(uniqueKeysWithValues:)-Trap).
        let vm = LearnViewModel()
        let a = Aircraft(manufacturer: "M", family: "F", variant: "A", icaoCode: "AAAA")
        let dup1 = LearningRecord(aircraftICAO: "AAAA", mode: "photo")
        let dup2 = LearningRecord(aircraftICAO: "AAAA", mode: "photo")
        XCTAssertNotNil(vm.pickAircraft(from: [a], records: [dup1, dup2], mode: .photo))
    }

    // MARK: – DatabaseViewModel (Phase E)

    private func makeFilterFixture() -> (DatabaseViewModel, Aircraft) {
        let vm = DatabaseViewModel()
        let a320 = Aircraft(manufacturer: "Airbus", family: "A320", variant: "A320neo",
                            icaoCode: "A20N", iataCode: "32N", status: .inProduction)
        return (vm, a320)
    }

    func testIsMatchingSearchByICAOAndVariant() throws {
        let (vm, a320) = makeFilterFixture()
        vm.searchText = "a20n"
        XCTAssertTrue(vm.isMatching(a320))
        vm.searchText = "320NEO"
        XCTAssertTrue(vm.isMatching(a320))
        vm.searchText = "Boeing"
        XCTAssertFalse(vm.isMatching(a320))
    }

    func testIsMatchingManufacturerAndStatusFilter() throws {
        let (vm, a320) = makeFilterFixture()
        vm.selectedManufacturers = ["Boeing"]
        XCTAssertFalse(vm.isMatching(a320))
        vm.selectedManufacturers = ["Airbus"]
        XCTAssertTrue(vm.isMatching(a320))
        vm.selectedStatuses = [.retired]
        XCTAssertFalse(vm.isMatching(a320))
    }

    func testIsMatchingFavoritesOnly() throws {
        let (vm, a320) = makeFilterFixture()
        vm.favoritesOnly = true
        XCTAssertFalse(vm.isMatching(a320))
        a320.isFavorite = true
        XCTAssertTrue(vm.isMatching(a320))
        XCTAssertTrue(vm.hasActiveFilters)
        vm.clearFilters()
        XCTAssertFalse(vm.favoritesOnly)
    }

    // MARK: – Helpers

    private func makeResult(confidence: Float) -> ClassificationResult {
        ClassificationResult(aircraft: nil, icaoLabel: "TEST", confidence: confidence)
    }
}
