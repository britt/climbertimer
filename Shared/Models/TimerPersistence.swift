import Foundation

/// Persisted timer state for background restoration
public struct PersistedTimerState: Codable {
    public let schedule: PhaseSchedule
    public let isPaused: Bool
    public let pausedAt: Date?
    public let pausedTimeRemaining: TimeInterval?

    public init(schedule: PhaseSchedule, isPaused: Bool, pausedAt: Date?, pausedTimeRemaining: TimeInterval?) {
        self.schedule = schedule
        self.isPaused = isPaused
        self.pausedAt = pausedAt
        self.pausedTimeRemaining = pausedTimeRemaining
    }
}

/// Handles persistence of timer state to UserDefaults
public final class TimerPersistence {
    public static let scheduleKey = "activeTimerState"

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func save(schedule: PhaseSchedule, isPaused: Bool, pausedAt: Date?) {
        let pausedTimeRemaining: TimeInterval?
        if isPaused, let pauseTime = pausedAt {
            pausedTimeRemaining = schedule.timeRemaining(at: pauseTime)
        } else {
            pausedTimeRemaining = nil
        }

        let state = PersistedTimerState(
            schedule: schedule,
            isPaused: isPaused,
            pausedAt: pausedAt,
            pausedTimeRemaining: pausedTimeRemaining
        )

        if let data = try? encoder.encode(state) {
            userDefaults.set(data, forKey: Self.scheduleKey)
        }
    }

    public func load() -> PersistedTimerState? {
        guard let data = userDefaults.data(forKey: Self.scheduleKey) else { return nil }
        return try? decoder.decode(PersistedTimerState.self, from: data)
    }

    public func clear() {
        userDefaults.removeObject(forKey: Self.scheduleKey)
    }
}
