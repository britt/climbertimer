import XCTest
import SwiftData
@testable import ClimberTimer

final class PresetStoreTests: XCTestCase {

    var presetStore: PresetStore!
    var modelContainer: ModelContainer!
    var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: Interval.self, configurations: config)
        testDefaults = UserDefaults(suiteName: "DataStoreTests")!
        // Clear all stored data before each test
        testDefaults.removePersistentDomain(forName: "DataStoreTests")
        testDefaults.removeObject(forKey: "lastUsedInterval")
        testDefaults.synchronize()
        presetStore = PresetStore(modelContainer: modelContainer, userDefaults: testDefaults)
    }

    override func tearDown() {
        presetStore = nil
        modelContainer = nil
        testDefaults = nil
        super.tearDown()
    }

    // MARK: - Presets

    func test_save_preset() throws {
        let interval = Interval(
            name: "Test Preset",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )

        try presetStore.savePreset(interval)

        let presets = presetStore.fetchPresets()
        XCTAssertEqual(presets.count, 1)
        XCTAssertEqual(presets.first?.name, "Test Preset")
    }

    func test_fetch_presets_ordered_by_creation_date() throws {
        let interval1 = Interval(name: "First", workDuration: 5, restDuration: 2, repetitions: 3, createdAt: Date(timeIntervalSinceNow: -100))
        let interval2 = Interval(name: "Second", workDuration: 7, restDuration: 3, repetitions: 6, createdAt: Date())

        try presetStore.savePreset(interval1)
        try presetStore.savePreset(interval2)

        let presets = presetStore.fetchPresets()
        XCTAssertEqual(presets.count, 2)
        XCTAssertEqual(presets[0].name, "Second") // Most recent first
        XCTAssertEqual(presets[1].name, "First")
    }

    func test_delete_preset() throws {
        let interval = Interval(name: "To Delete", workDuration: 5, restDuration: 2, repetitions: 3)
        try presetStore.savePreset(interval)

        var presets = presetStore.fetchPresets()
        XCTAssertEqual(presets.count, 1)

        try presetStore.deletePreset(presets[0])

        presets = presetStore.fetchPresets()
        XCTAssertEqual(presets.count, 0)
    }

    // MARK: - Last Used

    func test_save_and_load_last_used() {
        let interval = Interval(
            name: "Last Used",
            workDuration: 10,
            restDuration: 5,
            repetitions: 4
        )

        presetStore.saveLastUsed(interval)

        let loaded = presetStore.loadLastUsed()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.workDuration, 10)
        XCTAssertEqual(loaded?.restDuration, 5)
        XCTAssertEqual(loaded?.repetitions, 4)
    }

    func test_load_last_used_returns_default_when_none_saved() {
        // When nothing is saved, PresetStore returns defaultQuickStart
        let loaded = presetStore.loadLastUsed()
        XCTAssertNotNil(loaded)
        // Should be the default quick start values
        XCTAssertEqual(loaded?.workDuration, Interval.defaultQuickStart.workDuration)
        XCTAssertEqual(loaded?.restDuration, Interval.defaultQuickStart.restDuration)
        XCTAssertEqual(loaded?.repetitions, Interval.defaultQuickStart.repetitions)
    }
}
