import ActivityKit
import Foundation

public struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var phase: String
        public var phaseColor: String
        public var timeRemaining: TimeInterval
        public var currentRep: Int
        public var totalReps: Int
        public var endTime: Date

        public init(
            phase: String,
            phaseColor: String,
            timeRemaining: TimeInterval,
            currentRep: Int,
            totalReps: Int,
            endTime: Date
        ) {
            self.phase = phase
            self.phaseColor = phaseColor
            self.timeRemaining = timeRemaining
            self.currentRep = currentRep
            self.totalReps = totalReps
            self.endTime = endTime
        }
    }

    public var timerName: String
    public var workDuration: TimeInterval
    public var restDuration: TimeInterval

    public init(timerName: String, workDuration: TimeInterval, restDuration: TimeInterval) {
        self.timerName = timerName
        self.workDuration = workDuration
        self.restDuration = restDuration
    }
}
