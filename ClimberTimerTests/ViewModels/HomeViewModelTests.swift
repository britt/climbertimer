import XCTest
import SwiftData
@testable import ClimberTimer

final class HomeViewModelTests: XCTestCase {

    var viewModel: HomeViewModel!
    var presetStore: PresetStore!
    var modelContainer: ModelContainer!
    var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: Interval.self, configurations: config)
        testDefaults = UserDefaults(suiteName: "HomeViewModelTests")!
        testDefaults.removePersistentDomain(forName: "HomeViewModelTests")
        presetStore = PresetStore(modelContainer: modelContainer, userDefaults: testDefaults)
        viewModel = HomeViewModel(presetStore: presetStore)
    }

    override func tearDown() {
        viewModel = nil
        presetStore = nil
        modelContainer = nil
        testDefaults = nil
        super.tearDown()
    }

    func test_initial_values_are_defaults() {
        XCTAssertEqual(viewModel.workDuration, 7)
        XCTAssertEqual(viewModel.restDuration, 3)
        XCTAssertEqual(viewModel.repetitions, 6)
    }

    func test_loads_last_used_on_init() {
        let lastUsed = Interval(name: "", workDuration: 10, restDuration: 5, repetitions: 4)
        presetStore.saveLastUsed(lastUsed)

        viewModel = HomeViewModel(presetStore: presetStore)

        XCTAssertEqual(viewModel.workDuration, 10)
        XCTAssertEqual(viewModel.restDuration, 5)
        XCTAssertEqual(viewModel.repetitions, 4)
    }

    func test_create_interval_from_current_values() {
        viewModel.workDuration = 8
        viewModel.restDuration = 4
        viewModel.repetitions = 5

        let interval = viewModel.createInterval()

        XCTAssertEqual(interval.workDuration, 8)
        XCTAssertEqual(interval.restDuration, 4)
        XCTAssertEqual(interval.repetitions, 5)
    }

    func test_save_as_last_used() {
        viewModel.workDuration = 12
        viewModel.restDuration = 6
        viewModel.repetitions = 8

        viewModel.saveAsLastUsed()

        let loaded = presetStore.loadLastUsed()
        XCTAssertEqual(loaded?.workDuration, 12)
        XCTAssertEqual(loaded?.restDuration, 6)
        XCTAssertEqual(loaded?.repetitions, 8)
    }
}
