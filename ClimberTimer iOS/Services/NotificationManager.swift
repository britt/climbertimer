import Foundation
import UserNotifications

@Observable
public final class NotificationManager {
    private let notificationCenter = UNUserNotificationCenter.current()
    public let notificationPrefix = "climbertimer_phase_"

    public private(set) var isAuthorized: Bool = false

    public init() {}

    // MARK: - Notification Count Calculation

    /// Calculate how many notifications would be scheduled for a given schedule.
    /// This is useful for testing without needing notification permissions.
    public func calculateNotificationCount(for schedule: PhaseSchedule) -> Int {
        var count = 0
        let now = Date()

        // Count phases (excluding countdown) that are in the future
        for phase in schedule.phases {
            if phase.phase == .countdown { continue }
            if phase.startTime.timeIntervalSince(now) > 0 {
                count += 1
            }
        }

        // Add finished notification if end time is in the future
        if schedule.endTime.timeIntervalSince(now) > 0 {
            count += 1
        }

        return count
    }

    // MARK: - Authorization

    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            return false
        }
    }

    public func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Scheduling

    public func scheduleNotifications(for schedule: PhaseSchedule) async {
        // Cancel any existing timer notifications
        await cancelAllTimerNotifications()

        var notificationIndex = 0

        // Schedule notifications for each phase transition (excluding countdown)
        for phase in schedule.phases {
            // Skip countdown - we only notify when phases after countdown start
            if phase.phase == .countdown { continue }

            let content = UNMutableNotificationContent()
            content.title = notificationTitle(for: phase.phase, rep: phase.rep, totalReps: schedule.totalReps)
            content.body = notificationBody(for: phase.phase, rep: phase.rep, totalReps: schedule.totalReps)
            content.sound = .default
            content.categoryIdentifier = "TIMER_PHASE"

            // Calculate time until this phase starts
            let triggerDate = phase.startTime
            let timeInterval = triggerDate.timeIntervalSinceNow

            // Only schedule if in the future
            guard timeInterval > 0 else { continue }

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: timeInterval,
                repeats: false
            )

            let identifier = "\(notificationPrefix)\(notificationIndex)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch {
                print("Failed to schedule notification for \(phase.phase): \(error)")
            }
            notificationIndex += 1
        }

        // Schedule "finished" notification at the end of the timer
        let finishedTimeInterval = schedule.endTime.timeIntervalSinceNow
        if finishedTimeInterval > 0 {
            let finishedContent = UNMutableNotificationContent()
            finishedContent.title = notificationTitle(for: .finished, rep: schedule.totalReps, totalReps: schedule.totalReps)
            finishedContent.body = notificationBody(for: .finished, rep: schedule.totalReps, totalReps: schedule.totalReps)
            finishedContent.sound = .default
            finishedContent.categoryIdentifier = "TIMER_PHASE"

            let finishedTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: finishedTimeInterval,
                repeats: false
            )

            let finishedIdentifier = "\(notificationPrefix)\(notificationIndex)"
            let finishedRequest = UNNotificationRequest(
                identifier: finishedIdentifier,
                content: finishedContent,
                trigger: finishedTrigger
            )

            do {
                try await notificationCenter.add(finishedRequest)
            } catch {
                print("Failed to schedule finished notification: \(error)")
            }
        }
    }

    public func cancelAllTimerNotifications() async {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let timerIdentifiers = pendingRequests
            .filter { $0.identifier.hasPrefix(notificationPrefix) }
            .map { $0.identifier }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: timerIdentifiers)
    }

    public func pendingNotificationCount() async -> Int {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        return pendingRequests.filter { $0.identifier.hasPrefix(notificationPrefix) }.count
    }

    // MARK: - Remaining Notifications (for Resume)

    /// Calculate how many notifications would be scheduled for remaining phases.
    /// Used for testing notification rescheduling on resume.
    /// - Parameters:
    ///   - schedule: The original timer schedule
    ///   - fromPhaseIndex: The index of the current phase (notifications scheduled for phases after this)
    ///   - resumeTime: The time when the timer is being resumed
    /// - Returns: The number of notifications that would be scheduled
    public func calculateRemainingNotificationCount(
        for schedule: PhaseSchedule,
        fromPhaseIndex: Int,
        resumeTime: Date
    ) -> Int {
        var count = 0

        // Calculate the time offset: how much time elapsed in original schedule up to current phase
        guard fromPhaseIndex < schedule.phases.count else { return 1 } // Just finished notification

        let currentPhase = schedule.phases[fromPhaseIndex]
        let elapsedInOriginalSchedule = currentPhase.startTime.timeIntervalSince(schedule.startTime)

        // For each remaining phase after the current one, calculate when it would occur
        for index in (fromPhaseIndex + 1)..<schedule.phases.count {
            let phase = schedule.phases[index]
            // Skip countdown notifications (we don't notify on countdown)
            if phase.phase == .countdown { continue }

            // Calculate when this phase would start relative to resume time
            let originalPhaseStart = phase.startTime.timeIntervalSince(schedule.startTime)
            let adjustedTimeFromNow = originalPhaseStart - elapsedInOriginalSchedule

            if adjustedTimeFromNow > 0 {
                count += 1
            }
        }

        // Add finished notification if end time is in the future
        let originalEndTime = schedule.endTime.timeIntervalSince(schedule.startTime)
        let adjustedEndTimeFromNow = originalEndTime - elapsedInOriginalSchedule
        if adjustedEndTimeFromNow > 0 {
            count += 1
        }

        return count
    }

    /// Schedule notifications for remaining phases when resuming a timer.
    /// - Parameters:
    ///   - schedule: The original timer schedule
    ///   - fromPhaseIndex: The index of the current phase
    ///   - timeRemainingInPhase: Time remaining in the current phase
    public func scheduleRemainingNotifications(
        for schedule: PhaseSchedule,
        fromPhaseIndex: Int,
        timeRemainingInPhase: TimeInterval
    ) async {
        // Cancel any existing timer notifications first
        await cancelAllTimerNotifications()

        guard fromPhaseIndex < schedule.phases.count else { return }

        var notificationIndex = 0
        let currentPhase = schedule.phases[fromPhaseIndex]

        // Time until current phase ends
        var nextPhaseStartsIn = timeRemainingInPhase

        // Schedule notifications for phases after the current one
        for index in (fromPhaseIndex + 1)..<schedule.phases.count {
            let phase = schedule.phases[index]

            // Skip countdown notifications
            if phase.phase == .countdown { continue }

            let content = UNMutableNotificationContent()
            content.title = notificationTitle(for: phase.phase, rep: phase.rep, totalReps: schedule.totalReps)
            content.body = notificationBody(for: phase.phase, rep: phase.rep, totalReps: schedule.totalReps)
            content.sound = .default
            content.categoryIdentifier = "TIMER_PHASE"

            // Only schedule if in the future
            guard nextPhaseStartsIn > 0 else {
                nextPhaseStartsIn += phase.duration
                continue
            }

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: nextPhaseStartsIn,
                repeats: false
            )

            let identifier = "\(notificationPrefix)\(notificationIndex)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch {
                print("Failed to schedule notification for \(phase.phase): \(error)")
            }
            notificationIndex += 1

            // Add this phase's duration for the next phase timing
            nextPhaseStartsIn += phase.duration
        }

        // Schedule "finished" notification
        // Calculate total remaining time
        var totalRemainingTime = timeRemainingInPhase
        for index in (fromPhaseIndex + 1)..<schedule.phases.count {
            totalRemainingTime += schedule.phases[index].duration
        }

        if totalRemainingTime > 0 {
            let finishedContent = UNMutableNotificationContent()
            finishedContent.title = notificationTitle(for: .finished, rep: schedule.totalReps, totalReps: schedule.totalReps)
            finishedContent.body = notificationBody(for: .finished, rep: schedule.totalReps, totalReps: schedule.totalReps)
            finishedContent.sound = .default
            finishedContent.categoryIdentifier = "TIMER_PHASE"

            let finishedTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: totalRemainingTime,
                repeats: false
            )

            let finishedIdentifier = "\(notificationPrefix)\(notificationIndex)"
            let finishedRequest = UNNotificationRequest(
                identifier: finishedIdentifier,
                content: finishedContent,
                trigger: finishedTrigger
            )

            do {
                try await notificationCenter.add(finishedRequest)
            } catch {
                print("Failed to schedule finished notification: \(error)")
            }
        }
    }

    // MARK: - Notification Content

    private func notificationTitle(for phase: TimerPhase, rep: Int, totalReps: Int) -> String {
        switch phase {
        case .countdown:
            return "Get Ready!"
        case .work:
            return "WORK - Rep \(rep)/\(totalReps)"
        case .rest:
            return "REST - Rep \(rep)/\(totalReps)"
        case .finished:
            return "Timer Complete!"
        }
    }

    private func notificationBody(for phase: TimerPhase, rep: Int, totalReps: Int) -> String {
        switch phase {
        case .countdown:
            return "Timer starting..."
        case .work:
            return "Time to climb! Go!"
        case .rest:
            return "Take a break, shake it out."
        case .finished:
            return "Great session! All \(totalReps) reps complete."
        }
    }
}
