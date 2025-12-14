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

        XCTAssertEqual(timer.currentPhase, .work)
        XCTAssertEqual(timer.currentRep, 1)
        XCTAssertEqual(timer.timeRemaining, 7)
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

        XCTAssertEqual(timer.currentPhase, .work)
        XCTAssertEqual(timer.currentRep, 1)
        XCTAssertEqual(timer.timeRemaining, 7)
        XCTAssertFalse(timer.isRunning)
    }

    // MARK: - Countdown Logic

    func test_tick_decrements_time_remaining() {
        let interval = Interval(name: "Test", workDuration: 7, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.simulateTick(seconds: 1)

        XCTAssertEqual(timer.timeRemaining, 6, accuracy: 0.1)
    }

    func test_work_phase_ends_transitions_to_rest() {
        let interval = Interval(name: "Test", workDuration: 2, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        timer.simulateTick(seconds: 2)

        XCTAssertEqual(timer.currentPhase, .rest)
        XCTAssertEqual(timer.timeRemaining, 3, accuracy: 0.1)
    }

    func test_rest_phase_ends_increments_rep_and_returns_to_work() {
        let interval = Interval(name: "Test", workDuration: 2, restDuration: 3, repetitions: 6)
        let timer = IntervalTimer(interval: interval)

        // Complete work phase
        timer.simulateTick(seconds: 2)
        // Complete rest phase
        timer.simulateTick(seconds: 3)

        XCTAssertEqual(timer.currentPhase, .work)
        XCTAssertEqual(timer.currentRep, 2)
        XCTAssertEqual(timer.timeRemaining, 2, accuracy: 0.1)
    }

    func test_final_rep_ends_transitions_to_finished() {
        let interval = Interval(name: "Test", workDuration: 1, restDuration: 1, repetitions: 2)
        let timer = IntervalTimer(interval: interval)

        // Rep 1: work + rest
        timer.simulateTick(seconds: 2)
        // Rep 2: work + rest
        timer.simulateTick(seconds: 2)

        XCTAssertEqual(timer.currentPhase, .finished)
        XCTAssertFalse(timer.isRunning)
    }

    // MARK: - Countdown Warning

    func test_isInCountdownWarning_true_when_3_seconds_or_less() {
        let interval = Interval(name: "Test", workDuration: 5, restDuration: 3, repetitions: 1)
        let timer = IntervalTimer(interval: interval)

        XCTAssertFalse(timer.isInCountdownWarning) // 5 seconds

        timer.simulateTick(seconds: 2) // 3 seconds remaining
        XCTAssertTrue(timer.isInCountdownWarning)

        timer.simulateTick(seconds: 1) // 2 seconds remaining
        XCTAssertTrue(timer.isInCountdownWarning)
    }

    func test_countdownWarningSecond_returns_current_warning_second() {
        let interval = Interval(name: "Test", workDuration: 5, restDuration: 3, repetitions: 1)
        let timer = IntervalTimer(interval: interval)

        timer.simulateTick(seconds: 2) // 3 seconds remaining
        XCTAssertEqual(timer.countdownWarningSecond, 3)

        timer.simulateTick(seconds: 1) // 2 seconds remaining
        XCTAssertEqual(timer.countdownWarningSecond, 2)

        timer.simulateTick(seconds: 1) // 1 second remaining
        XCTAssertEqual(timer.countdownWarningSecond, 1)
    }
}
