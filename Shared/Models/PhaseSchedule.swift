import Foundation

/// Represents a single scheduled phase with its absolute start/end times
public struct ScheduledPhase: Codable, Equatable {
    public let phase: TimerPhase
    public let rep: Int
    public let startTime: Date
    public let endTime: Date
    public let duration: TimeInterval

    public init(phase: TimerPhase, rep: Int, startTime: Date, duration: TimeInterval) {
        self.phase = phase
        self.rep = rep
        self.startTime = startTime
        self.duration = duration
        self.endTime = startTime.addingTimeInterval(duration)
    }
}

/// Pre-calculated schedule of all phase transitions for zero-drift background timing
public struct PhaseSchedule: Codable, Equatable {
    public let intervalId: UUID
    public let intervalName: String
    public let startTime: Date
    public let endTime: Date
    public let phases: [ScheduledPhase]
    public let totalReps: Int

    private static let countdownDuration: TimeInterval = 3

    public init(interval: Interval, startTime: Date) {
        self.intervalId = interval.id
        self.intervalName = interval.name
        self.startTime = startTime
        self.totalReps = interval.repetitions

        var phases: [ScheduledPhase] = []
        var currentTime = startTime

        // Countdown phase
        let countdown = ScheduledPhase(
            phase: .countdown,
            rep: 1,
            startTime: currentTime,
            duration: Self.countdownDuration
        )
        phases.append(countdown)
        currentTime = countdown.endTime

        // Work/Rest cycles
        for rep in 1...interval.repetitions {
            // Work phase
            let work = ScheduledPhase(
                phase: .work,
                rep: rep,
                startTime: currentTime,
                duration: interval.workDuration
            )
            phases.append(work)
            currentTime = work.endTime

            // Rest phase
            let rest = ScheduledPhase(
                phase: .rest,
                rep: rep,
                startTime: currentTime,
                duration: interval.restDuration
            )
            phases.append(rest)
            currentTime = rest.endTime
        }

        self.phases = phases
        self.endTime = currentTime
    }

    /// Find the current phase at a given timestamp
    /// Returns nil if the timestamp is after the schedule ends
    public func currentPhase(at date: Date) -> ScheduledPhase? {
        for phase in phases {
            if date >= phase.startTime && date < phase.endTime {
                return phase
            }
        }
        return nil
    }

    /// Calculate time remaining in the current phase
    public func timeRemaining(at date: Date) -> TimeInterval? {
        guard let current = currentPhase(at: date) else { return nil }
        return current.endTime.timeIntervalSince(date)
    }

    /// Check if the timer has finished
    public func isFinished(at date: Date) -> Bool {
        return date >= endTime
    }
}
