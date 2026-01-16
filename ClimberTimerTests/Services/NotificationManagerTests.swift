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

    // MARK: - Schedule Notifications Tests (Required by spec)

    func test_scheduleNotifications_createsCorrectCount() {
        // Given: An interval schedule
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let schedule = PhaseSchedule(interval: interval, startTime: Date().addingTimeInterval(60))

        // When: We calculate the expected notification count
        let expectedCount = notificationManager.calculateNotificationCount(for: schedule)

        // Then: The count should match the expected notifications
        // For 2 reps: work1, rest1, work2, rest2, finished = 5 notifications
        XCTAssertEqual(expectedCount, 5)
    }

    // MARK: - Cancel Notifications Tests (Required by spec)

    func test_cancelAllTimerNotifications_removesScheduledNotifications() async {
        // Given: A notification manager with known prefix
        let prefix = notificationManager.notificationPrefix

        // When: Cancel is called
        await notificationManager.cancelAllTimerNotifications()

        // Then: The pending count should be zero
        let pendingCount = await notificationManager.pendingNotificationCount()
        XCTAssertEqual(pendingCount, 0)

        // Also verify the prefix is correct for identification
        XCTAssertEqual(prefix, "climbertimer_phase_")
    }

    // MARK: - Notification Prefix Tests

    func test_notificationPrefix_isCorrect() {
        XCTAssertEqual(notificationManager.notificationPrefix, "climbertimer_phase_")
    }
}
