import XCTest
@testable import ClimberTimer

final class BackgroundTimerCoordinatorTests: XCTestCase {

    var coordinator: BackgroundTimerCoordinator!
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "CoordinatorTestDefaults")!
        userDefaults.removePersistentDomain(forName: "CoordinatorTestDefaults")
        coordinator = BackgroundTimerCoordinator(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "CoordinatorTestDefaults")
        super.tearDown()
    }

    // MARK: - Start Timer Tests

    func test_startTimer_createsScheduleAndTimer() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)

        await coordinator.startTimer(with: interval)

        XCTAssertNotNil(coordinator.timer)
        XCTAssertNotNil(coordinator.schedule)
        XCTAssertTrue(coordinator.timer?.isRunning ?? false)
    }

    func test_startTimer_persistsState() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let persistence = TimerPersistence(userDefaults: userDefaults)

        await coordinator.startTimer(with: interval)

        let state = persistence.load()
        XCTAssertNotNil(state)
        XCTAssertFalse(state?.isPaused ?? true)
    }

    // MARK: - Pause Timer Tests

    func test_pauseTimer_stopsRunningTimer() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)

        await coordinator.startTimer(with: interval)
        await coordinator.pauseTimer()

        XCTAssertFalse(coordinator.timer?.isRunning ?? true)
    }

    func test_pauseTimer_persistsPausedState() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let persistence = TimerPersistence(userDefaults: userDefaults)

        await coordinator.startTimer(with: interval)
        await coordinator.pauseTimer()

        let state = persistence.load()
        XCTAssertNotNil(state)
        XCTAssertTrue(state?.isPaused ?? false)
    }

    // MARK: - Resume Timer Tests

    func test_resumeTimer_restartsTimer() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)

        await coordinator.startTimer(with: interval)
        await coordinator.pauseTimer()
        await coordinator.resumeTimer()

        XCTAssertTrue(coordinator.timer?.isRunning ?? false)
    }

    func test_resumeTimer_persistsRunningState() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let persistence = TimerPersistence(userDefaults: userDefaults)

        await coordinator.startTimer(with: interval)
        await coordinator.pauseTimer()
        await coordinator.resumeTimer()

        let state = persistence.load()
        XCTAssertNotNil(state)
        XCTAssertFalse(state?.isPaused ?? true)
    }

    // MARK: - Reset Timer Tests

    func test_resetTimer_clearsState() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)

        await coordinator.startTimer(with: interval)
        await coordinator.resetTimer()

        XCTAssertNil(coordinator.timer)
        XCTAssertNil(coordinator.schedule)
    }

    func test_resetTimer_clearsPersistence() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let persistence = TimerPersistence(userDefaults: userDefaults)

        await coordinator.startTimer(with: interval)
        await coordinator.resetTimer()

        let state = persistence.load()
        XCTAssertNil(state)
    }

    // MARK: - Restore From Background Tests

    func test_restoreFromBackground_withNoSavedState_doesNothing() async {
        await coordinator.restoreFromBackground()

        XCTAssertNil(coordinator.timer)
        XCTAssertNil(coordinator.schedule)
    }

    func test_restoreFromBackground_withRunningState_restoresTimer() async {
        // Setup: Start a timer and save state
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        await coordinator.startTimer(with: interval)

        // Create a new coordinator to simulate app restart
        let newCoordinator = BackgroundTimerCoordinator(userDefaults: userDefaults)

        // Restore
        await newCoordinator.restoreFromBackground()

        // Timer should be restored and running
        XCTAssertNotNil(newCoordinator.timer)
        XCTAssertNotNil(newCoordinator.schedule)
        XCTAssertTrue(newCoordinator.timer?.isRunning ?? false)
    }

    func test_restoreFromBackground_withPausedState_restoresPausedTimer() async {
        // Setup: Start and pause a timer
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        await coordinator.startTimer(with: interval)
        await coordinator.pauseTimer()

        // Create a new coordinator to simulate app restart
        let newCoordinator = BackgroundTimerCoordinator(userDefaults: userDefaults)

        // Restore
        await newCoordinator.restoreFromBackground()

        // Timer should be restored but NOT running (paused)
        XCTAssertNotNil(newCoordinator.timer)
        XCTAssertNotNil(newCoordinator.schedule)
        XCTAssertFalse(newCoordinator.timer?.isRunning ?? true)
    }

    // MARK: - Schedule Creation Tests

    func test_startTimer_createsCorrectSchedule() async {
        let interval = Interval(name: "Test Interval", workDuration: 7, restDuration: 3, repetitions: 2)

        await coordinator.startTimer(with: interval)

        XCTAssertEqual(coordinator.schedule?.intervalName, "Test Interval")
        XCTAssertEqual(coordinator.schedule?.totalReps, 2)
    }

    func test_timer_startsInCountdownPhase() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)

        await coordinator.startTimer(with: interval)

        XCTAssertEqual(coordinator.timer?.currentPhase, .countdown)
        XCTAssertEqual(coordinator.timer?.currentRep, 1)
    }
}
