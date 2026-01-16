import Foundation
import ActivityKit

@Observable
public final class LiveActivityManager {
    public private(set) var isActive: Bool = false
    private var currentActivity: Activity<TimerActivityAttributes>?

    public init() {}

    // MARK: - Activity Lifecycle

    public func startActivity(
        schedule: PhaseSchedule,
        currentPhase: TimerPhase,
        currentRep: Int,
        timeRemaining: TimeInterval
    ) async {
        // End any existing activity
        await endActivity()

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        let attributes = TimerActivityAttributes(
            timerName: schedule.intervalName,
            workDuration: schedule.workDuration,
            restDuration: schedule.restDuration
        )

        let initialState = TimerActivityAttributes.ContentState(
            phase: currentPhase.displayName,
            phaseColor: currentPhase.colorName,
            timeRemaining: timeRemaining,
            currentRep: currentRep,
            totalReps: schedule.totalReps,
            endTime: Date().addingTimeInterval(timeRemaining)
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            await MainActor.run {
                self.isActive = true
            }
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    public func updateActivity(
        phase: TimerPhase,
        rep: Int,
        totalReps: Int,
        timeRemaining: TimeInterval
    ) async {
        guard let activity = currentActivity else { return }

        let updatedState = TimerActivityAttributes.ContentState(
            phase: phase.displayName,
            phaseColor: phase.colorName,
            timeRemaining: timeRemaining,
            currentRep: rep,
            totalReps: totalReps,
            endTime: Date().addingTimeInterval(timeRemaining)
        )

        await activity.update(
            ActivityContent(state: updatedState, staleDate: nil)
        )
    }

    public func endActivity() async {
        guard let activity = currentActivity else { return }

        let finalState = TimerActivityAttributes.ContentState(
            phase: TimerPhase.finished.displayName,
            phaseColor: TimerPhase.finished.colorName,
            timeRemaining: 0,
            currentRep: 0,
            totalReps: 0,
            endTime: Date()
        )

        await activity.end(
            ActivityContent(state: finalState, staleDate: nil),
            dismissalPolicy: .immediate
        )

        currentActivity = nil
        await MainActor.run {
            self.isActive = false
        }
    }
}
