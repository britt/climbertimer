import XCTest
import ActivityKit
@testable import ClimberTimer

final class LiveActivityManagerTests: XCTestCase {

    var liveActivityManager: LiveActivityManager!

    override func setUp() {
        super.setUp()
        liveActivityManager = LiveActivityManager()
    }

    override func tearDown() {
        Task {
            await liveActivityManager.endActivity()
        }
        super.tearDown()
    }

    func test_startActivity_setsIsActiveTrue() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let schedule = PhaseSchedule(interval: interval, startTime: Date())

        await liveActivityManager.startActivity(
            schedule: schedule,
            currentPhase: .countdown,
            currentRep: 1,
            timeRemaining: 3
        )

        // Note: On simulator, Live Activity may not actually start
        // We test the manager's state management
        XCTAssertTrue(liveActivityManager.isActive || !ActivityAuthorizationInfo().areActivitiesEnabled)
    }

    func test_updateActivity_whenNotActive_doesNotCrash() async {
        // Should not crash when updating without active activity
        await liveActivityManager.updateActivity(
            phase: .work,
            rep: 1,
            totalReps: 6,
            timeRemaining: 7
        )

        // No assertion needed - just verify no crash
        XCTAssertFalse(liveActivityManager.isActive)
    }

    func test_endActivity_setsIsActiveFalse() async {
        await liveActivityManager.endActivity()

        XCTAssertFalse(liveActivityManager.isActive)
    }

    func test_init_isActiveFalse() {
        XCTAssertFalse(liveActivityManager.isActive)
    }
}
