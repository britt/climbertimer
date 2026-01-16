import XCTest
@testable import ClimberTimer

final class TimerPersistenceTests: XCTestCase {

    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "TestDefaults")!
        userDefaults.removePersistentDomain(forName: "TestDefaults")
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        super.tearDown()
    }

    func test_save_storesScheduleToUserDefaults() {
        let persistence = TimerPersistence(userDefaults: userDefaults)
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let schedule = PhaseSchedule(interval: interval, startTime: Date())

        persistence.save(schedule: schedule, isPaused: false, pausedAt: nil)

        XCTAssertNotNil(userDefaults.data(forKey: TimerPersistence.scheduleKey))
    }

    func test_load_returnsNilWhenEmpty() {
        let persistence = TimerPersistence(userDefaults: userDefaults)

        let loaded = persistence.load()

        XCTAssertNil(loaded)
    }

    func test_load_returnsSavedState() {
        let persistence = TimerPersistence(userDefaults: userDefaults)
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let schedule = PhaseSchedule(interval: interval, startTime: Date())

        persistence.save(schedule: schedule, isPaused: false, pausedAt: nil)
        let loaded = persistence.load()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.schedule.intervalName, "Test")
        XCTAssertFalse(loaded?.isPaused ?? true)
    }

    func test_clear_removesPersistedState() {
        let persistence = TimerPersistence(userDefaults: userDefaults)
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let schedule = PhaseSchedule(interval: interval, startTime: Date())

        persistence.save(schedule: schedule, isPaused: false, pausedAt: nil)
        persistence.clear()
        let loaded = persistence.load()

        XCTAssertNil(loaded)
    }

    func test_save_pausedState_storesTimeRemaining() {
        let persistence = TimerPersistence(userDefaults: userDefaults)
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let startTime = Date()
        let schedule = PhaseSchedule(interval: interval, startTime: startTime)
        let pausedAt = startTime.addingTimeInterval(1) // 1s into countdown

        persistence.save(schedule: schedule, isPaused: true, pausedAt: pausedAt)
        let loaded = persistence.load()

        XCTAssertNotNil(loaded)
        XCTAssertTrue(loaded?.isPaused ?? false)
        XCTAssertEqual(loaded?.pausedTimeRemaining ?? 0, 2, accuracy: 0.01) // 2s remaining in countdown
    }
}
