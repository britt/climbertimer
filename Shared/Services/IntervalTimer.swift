import Foundation
import Combine

@Observable
public class IntervalTimer {
    public private(set) var currentPhase: TimerPhase = .work
    public private(set) var currentRep: Int = 1
    public private(set) var timeRemaining: TimeInterval = 0
    public private(set) var isRunning: Bool = false

    public let totalReps: Int

    private let workDuration: TimeInterval
    private let restDuration: TimeInterval
    private var timerCancellable: AnyCancellable?

    public init(interval: Interval) {
        self.workDuration = interval.workDuration
        self.restDuration = interval.restDuration
        self.totalReps = interval.repetitions
        self.timeRemaining = interval.workDuration
    }

    // MARK: - Controls

    public func start() {
        isRunning = true
        startTimer()
    }

    public func pause() {
        isRunning = false
        timerCancellable?.cancel()
    }

    public func resume() {
        isRunning = true
        startTimer()
    }

    public func reset() {
        timerCancellable?.cancel()
        isRunning = false
        currentPhase = .work
        currentRep = 1
        timeRemaining = workDuration
    }

    // MARK: - Countdown Warning

    public var isInCountdownWarning: Bool {
        let rounded = (timeRemaining * 10).rounded() / 10  // Round to 1 decimal
        return rounded <= 3 && rounded > 0 && currentPhase != .finished
    }

    public var countdownWarningSecond: Int? {
        guard isInCountdownWarning else { return nil }
        let rounded = (timeRemaining * 10).rounded() / 10
        return Int(ceil(rounded))
    }

    // MARK: - Testing Support

    /// For testing - simulates elapsed time
    public func simulateTick(seconds: TimeInterval) {
        var remaining = seconds
        while remaining > 0.001 {
            let tickAmount = min(0.1, remaining)
            timeRemaining -= tickAmount
            remaining -= tickAmount

            // Round to avoid floating point drift
            timeRemaining = (timeRemaining * 100).rounded() / 100

            if timeRemaining <= 0.001 {
                handlePhaseTransition()
            }
        }
    }

    // MARK: - Private

    private func startTimer() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard isRunning else { return }

        timeRemaining -= 0.1

        if timeRemaining <= 0 {
            handlePhaseTransition()
        }
    }

    private func handlePhaseTransition() {
        switch currentPhase {
        case .work:
            currentPhase = .rest
            timeRemaining = restDuration

        case .rest:
            if currentRep >= totalReps {
                currentPhase = .finished
                isRunning = false
                timerCancellable?.cancel()
            } else {
                currentRep += 1
                currentPhase = .work
                timeRemaining = workDuration
            }

        case .finished:
            break
        }
    }
}
