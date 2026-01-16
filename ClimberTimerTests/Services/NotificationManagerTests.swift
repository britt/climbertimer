import XCTest
import UserNotifications
@testable import ClimberTimer

final class NotificationManagerTests: XCTestCase {

    var notificationManager: NotificationManager!

    override func setUp() {
        super.setUp()
        notificationManager = NotificationManager()
    }

    override func tearDown() async throws {
        // Clean up any notifications scheduled during tests
        await notificationManager.cancelAllTimerNotifications()
        notificationManager = nil
    }

    // MARK: - Initialization Tests

    func test_initialization_isAuthorizedIsFalse() {
        let manager = NotificationManager()

        XCTAssertFalse(manager.isAuthorized)
    }

    // MARK: - Notification Count Calculation Tests

    func test_calculateNotificationCount_forTwoReps_returnsFive() {
        // Given: An interval with 2 reps
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let schedule = PhaseSchedule(interval: interval, startTime: Date().addingTimeInterval(60))

        // When: We calculate how many notifications should be scheduled
        let expectedCount = notificationManager.calculateNotificationCount(for: schedule)

        // Then: We should expect 5 notifications
        // Phases: [countdown, work1, rest1, work2, rest2]
        // Skip countdown, notify on: work1, rest1, work2, rest2 = 4 phase starts
        // Plus finished notification at end = 5 total
        XCTAssertEqual(expectedCount, 5)
    }

    func test_calculateNotificationCount_forSingleRep_returnsThree() {
        // Given: An interval with 1 rep
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 1)
        let schedule = PhaseSchedule(interval: interval, startTime: Date().addingTimeInterval(60))

        // When: We calculate notification count
        let expectedCount = notificationManager.calculateNotificationCount(for: schedule)

        // Then: We should expect 3 notifications
        // Phases: [countdown, work1, rest1]
        // Skip countdown, notify on: work1, rest1 = 2 phase starts
        // Plus finished notification = 3 total
        XCTAssertEqual(expectedCount, 3)
    }

    func test_calculateNotificationCount_forThreeReps_returnsSeven() {
        // Given: An interval with 3 reps
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 3)
        let schedule = PhaseSchedule(interval: interval, startTime: Date().addingTimeInterval(60))

        // When: We calculate notification count
        let expectedCount = notificationManager.calculateNotificationCount(for: schedule)

        // Then: We should expect 7 notifications
        // Phases: [countdown, work1, rest1, work2, rest2, work3, rest3]
        // Skip countdown, notify on: work1, rest1, work2, rest2, work3, rest3 = 6 phase starts
        // Plus finished notification = 7 total
        XCTAssertEqual(expectedCount, 7)
    }

    func test_calculateNotificationCount_forPastSchedule_returnsZero() {
        // Given: A schedule that already started (in the past)
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let schedule = PhaseSchedule(interval: interval, startTime: Date().addingTimeInterval(-100))

        // When: We calculate notification count
        let expectedCount = notificationManager.calculateNotificationCount(for: schedule)

        // Then: We should expect 0 notifications (can't schedule for the past)
        XCTAssertEqual(expectedCount, 0)
    }

    // MARK: - Notification Content Tests

    func test_notificationContent_forWorkPhase_hasCorrectTitle() {
        // Test that notification titles are generated correctly
        let title = notificationManager.notificationTitle(for: .work, rep: 1, totalReps: 3)

        XCTAssertEqual(title, "WORK - Rep 1/3")
    }

    func test_notificationContent_forRestPhase_hasCorrectTitle() {
        let title = notificationManager.notificationTitle(for: .rest, rep: 2, totalReps: 3)

        XCTAssertEqual(title, "REST - Rep 2/3")
    }

    func test_notificationContent_forFinished_hasCorrectTitle() {
        let title = notificationManager.notificationTitle(for: .finished, rep: 3, totalReps: 3)

        XCTAssertEqual(title, "Timer Complete!")
    }

    func test_notificationContent_forWorkPhase_hasCorrectBody() {
        let body = notificationManager.notificationBody(for: .work, rep: 1, totalReps: 3)

        XCTAssertEqual(body, "Time to climb! Go!")
    }

    func test_notificationContent_forRestPhase_hasCorrectBody() {
        let body = notificationManager.notificationBody(for: .rest, rep: 1, totalReps: 3)

        XCTAssertEqual(body, "Take a break, shake it out.")
    }

    func test_notificationContent_forFinished_hasCorrectBody() {
        let body = notificationManager.notificationBody(for: .finished, rep: 3, totalReps: 3)

        XCTAssertEqual(body, "Great session! All 3 reps complete.")
    }

    func test_notificationContent_forCountdown_hasCorrectTitle() {
        let title = notificationManager.notificationTitle(for: .countdown, rep: 1, totalReps: 3)

        XCTAssertEqual(title, "Get Ready!")
    }

    func test_notificationContent_forCountdown_hasCorrectBody() {
        let body = notificationManager.notificationBody(for: .countdown, rep: 1, totalReps: 3)

        XCTAssertEqual(body, "Timer starting...")
    }

    // MARK: - Notification Prefix Tests

    func test_notificationPrefix_isCorrect() {
        XCTAssertEqual(notificationManager.notificationPrefix, "climbertimer_phase_")
    }
}
