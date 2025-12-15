import XCTest
@testable import ClimberTimer

final class IntervalTimerTests: XCTestCase {

    // MARK: - Initial State

    func test_initial_state() {
        let interval = Interval(
            name: "Test",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )
        let timer = IntervalTimer(interval: interval)

        XCTAssertEqual(timer.currentPhase, .countdown)
        XCTAssertEqual(timer.currentRep, 1)
        XCTAssertEqual(timer.timeRemaining, 3) // countdown duration
        XCTAssertFalse(timer.isRunning)
    }

    func test_total_reps() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        XCTAssertEqual(timer.totalReps, 6)
    }

    // MARK: - Start/Pause/Resume

    func test_start_sets_running_true() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.start()

        XCTAssertTrue(timer.isRunning)
    }

    func test_pause_sets_running_false() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.start()
        timer.pause()

        XCTAssertFalse(timer.isRunning)
    }

    func test_resume_sets_running_true() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.start()
        timer.pause()
        timer.resume()

        XCTAssertTrue(timer.isRunning)
    }

    // MARK: - Reset

    func test_reset_returns_to_initial_state() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.start()
        timer.pause()
        timer.reset()

        XCTAssertEqual(timer.currentPhase, .countdown)
        XCTAssertEqual(timer.currentRep, 1)
        XCTAssertEqual(timer.timeRemaining, 3) // countdown duration
        XCTAssertFalse(timer.isRunning)
    }

    // MARK: - Countdown Logic

    func test_tick_decrements_time_remaining() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.simulateTick(seconds: 1)

        // Started with 3 second countdown, now 2 remaining
        XCTAssertEqual(timer.timeRemaining, 2, accuracy: 0.1)
    }

    func test_countdown_phase_transitions_to_work() {
        let interval = Interval(name: "Test", workDuration: 2, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        // Complete 3 second countdown
        timer.simulateTick(seconds: 3)

        XCTAssertEqual(timer.currentPhase, .work)
        XCTAssertEqual(timer.timeRemaining, 2, accuracy: 0.1)
    }

    func test_work_phase_ends_transitions_to_rest() {
        let interval = Interval(name: "Test", workDuration: 2, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        // Complete countdown (3s) + work (2s)
        timer.simulateTick(seconds: 5)

        XCTAssertEqual(timer.currentPhase, .rest)
        XCTAssertEqual(timer.timeRemaining, 3, accuracy: 0.1)
    }

    func test_rest_phase_ends_increments_rep_and_returns_to_work() {
        let interval = Interval(name: "Test", workDuration: 2, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        // Complete countdown (3s) + work (2s) + rest (3s)
        timer.simulateTick(seconds: 8)

        XCTAssertEqual(timer.currentPhase, .work)
        XCTAssertEqual(timer.currentRep, 2)
        XCTAssertEqual(timer.timeRemaining, 2, accuracy: 0.1)
    }

    func test_final_rep_ends_transitions_to_finished() {
        let interval = Interval(name: "Test", workDuration: 1, restDuration: 1, repetitions: 2)
        let timer = IntervalTimer(interval: interval)

        // Countdown (3s) + Rep 1: work + rest (2s) + Rep 2: work + rest (2s)
        timer.simulateTick(seconds: 7)

        XCTAssertEqual(timer.currentPhase, .finished)
        XCTAssertFalse(timer.isRunning)
    }

    // MARK: - Countdown Warning

    func test_isInCountdownWarning_true_when_3_seconds_or_less() {
        let interval = Interval(name: "Test", workDuration: 5, restDuration: 3, repetitions: 1)
        let timer = IntervalTimer(interval: interval)

        // During initial countdown phase, warning is true (3 seconds)
        XCTAssertTrue(timer.isInCountdownWarning)

        // Skip countdown (3s) to get to work phase with 5 seconds
        timer.simulateTick(seconds: 3)
        XCTAssertEqual(timer.currentPhase, .work)
        XCTAssertFalse(timer.isInCountdownWarning) // 5 seconds

        timer.simulateTick(seconds: 2) // 3 seconds remaining in work
        XCTAssertTrue(timer.isInCountdownWarning)

        timer.simulateTick(seconds: 1) // 2 seconds remaining
        XCTAssertTrue(timer.isInCountdownWarning)
    }

    func test_countdownWarningSecond_returns_current_warning_second() {
        let interval = Interval(name: "Test", workDuration: 5, restDuration: 3, repetitions: 1)
        let timer = IntervalTimer(interval: interval)

        // Start in countdown phase - warning seconds work here too
        XCTAssertEqual(timer.countdownWarningSecond, 3)

        // Skip countdown (3s) to work phase with 5 seconds
        timer.simulateTick(seconds: 3)

        timer.simulateTick(seconds: 2) // 3 seconds remaining in work
        XCTAssertEqual(timer.countdownWarningSecond, 3)

        timer.simulateTick(seconds: 1) // 2 seconds remaining
        XCTAssertEqual(timer.countdownWarningSecond, 2)

        timer.simulateTick(seconds: 1) // 1 second remaining
        XCTAssertEqual(timer.countdownWarningSecond, 1)
    }
}
