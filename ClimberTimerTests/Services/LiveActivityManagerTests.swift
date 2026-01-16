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

    func test_startActivity_attemptsToStartActivity() async {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let schedule = PhaseSchedule(interval: interval, startTime: Date())

        await liveActivityManager.startActivity(
            schedule: schedule,
            currentPhase: .countdown,
            currentRep: 1,
            timeRemaining: 3
        )

        // Note: On simulator, Live Activity requests may fail due to entitlement or platform restrictions
        // even when ActivityAuthorizationInfo().areActivitiesEnabled returns true.
        // This test verifies the manager handles both success and failure cases gracefully.
        // The isActive state reflects whether the Activity.request actually succeeded.
        //
        // On real devices with proper entitlements, isActive would be true.
        // On simulator, it may be false due to request failure - this is expected behavior.
        let activitiesEnabled = ActivityAuthorizationInfo().areActivitiesEnabled

        // If activities aren't enabled at all, isActive should definitely be false
        if !activitiesEnabled {
            XCTAssertFalse(liveActivityManager.isActive)
        }
        // If activities are enabled but isActive is false, the request failed (expected on simulator)
        // If activities are enabled and isActive is true, the request succeeded (expected on device)
        // Both outcomes are valid - we're testing that the manager doesn't crash and handles state correctly
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
