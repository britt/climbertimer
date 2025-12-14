import XCTest
import SwiftData
@testable import ClimberTimer

final class PresetsViewModelTests: XCTestCase {

    var viewModel: PresetsViewModel!
    var presetStore: PresetStore!
    var modelContainer: ModelContainer!
    var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: Interval.self, configurations: config)
        testDefaults = UserDefaults(suiteName: "PresetsViewModelTests")!
        testDefaults.removePersistentDomain(forName: "PresetsViewModelTests")
        presetStore = PresetStore(modelContainer: modelContainer, userDefaults: testDefaults)
        viewModel = PresetsViewModel(presetStore: presetStore)
    }

    override func tearDown() {
        viewModel = nil
        presetStore = nil
        modelContainer = nil
        testDefaults = nil
        super.tearDown()
    }

    func test_presets_initially_empty() {
        XCTAssertTrue(viewModel.presets.isEmpty)
    }

    func test_load_presets() throws {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        try presetStore.savePreset(interval)

        viewModel.loadPresets()

        XCTAssertEqual(viewModel.presets.count, 1)
        XCTAssertEqual(viewModel.presets.first?.name, "Test")
    }

    func test_delete_preset() throws {
        let interval = Interval(name: "To Delete", workDuration: 7, restDuration: 3, repetitions: 6)
        try presetStore.savePreset(interval)
        viewModel.loadPresets()

        viewModel.deletePreset(at: IndexSet(integer: 0))

        XCTAssertTrue(viewModel.presets.isEmpty)
    }

    func test_save_current_as_preset() throws {
        viewModel.saveCurrentAsPreset(name: "New Preset", workDuration: 10, restDuration: 5, repetitions: 4)

        XCTAssertEqual(viewModel.presets.count, 1)
        XCTAssertEqual(viewModel.presets.first?.name, "New Preset")
        XCTAssertEqual(viewModel.presets.first?.workDuration, 10)
    }
}
