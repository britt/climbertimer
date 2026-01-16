import XCTest
@testable import ClimberTimer

final class PhaseScheduleTests: XCTestCase {

    func test_init_createsCorrectPhaseCount() {
        // Given: 7s work, 3s rest, 6 reps
        let interval = Interval(
            name: "Test",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )
        let startTime = Date()

        // When
        let schedule = PhaseSchedule(interval: interval, startTime: startTime)

        // Then: countdown + (work + rest) * 6 = 1 + 12 = 13 phases
        XCTAssertEqual(schedule.phases.count, 13)
    }

    func test_currentPhase_atStartTime_returnsCountdown() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let startTime = Date()
        let schedule = PhaseSchedule(interval: interval, startTime: startTime)

        let current = schedule.currentPhase(at: startTime)

        XCTAssertNotNil(current)
        XCTAssertEqual(current?.phase, .countdown)
        XCTAssertEqual(current?.rep, 1)
    }

    func test_currentPhase_duringWork_returnsWorkPhase() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let startTime = Date()
        let schedule = PhaseSchedule(interval: interval, startTime: startTime)

        // 3s countdown + 2s into work = 5s from start
        let checkTime = startTime.addingTimeInterval(5)
        let current = schedule.currentPhase(at: checkTime)

        XCTAssertNotNil(current)
        XCTAssertEqual(current?.phase, .work)
        XCTAssertEqual(current?.rep, 1)
    }

    func test_currentPhase_afterEnd_returnsNil() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let startTime = Date()
        let schedule = PhaseSchedule(interval: interval, startTime: startTime)

        // Way after timer ends
        let checkTime = startTime.addingTimeInterval(1000)
        let current = schedule.currentPhase(at: checkTime)

        XCTAssertNil(current)
    }

    func test_timeRemaining_duringPhase_returnsCorrectValue() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let startTime = Date()
        let schedule = PhaseSchedule(interval: interval, startTime: startTime)

        // 1 second into countdown (3s countdown)
        let checkTime = startTime.addingTimeInterval(1)
        let remaining = schedule.timeRemaining(at: checkTime)

        XCTAssertNotNil(remaining)
        XCTAssertEqual(remaining!, 2, accuracy: 0.001) // 2 seconds remaining
    }

    func test_isFinished_beforeEnd_returnsFalse() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let startTime = Date()
        let schedule = PhaseSchedule(interval: interval, startTime: startTime)

        let checkTime = startTime.addingTimeInterval(5)

        XCTAssertFalse(schedule.isFinished(at: checkTime))
    }

    func test_isFinished_afterEnd_returnsTrue() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let startTime = Date()
        let schedule = PhaseSchedule(interval: interval, startTime: startTime)

        let checkTime = startTime.addingTimeInterval(1000)

        XCTAssertTrue(schedule.isFinished(at: checkTime))
    }

    // MARK: - Duration Computed Properties Tests

    func test_workDuration_returnsCorrectValue() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let schedule = PhaseSchedule(interval: interval, startTime: Date())

        XCTAssertEqual(schedule.workDuration, 7)
    }

    func test_restDuration_returnsCorrectValue() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 2)
        let schedule = PhaseSchedule(interval: interval, startTime: Date())

        XCTAssertEqual(schedule.restDuration, 3)
    }
}
