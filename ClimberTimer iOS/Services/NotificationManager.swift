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

            try? await notificationCenter.add(request)
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

            try? await notificationCenter.add(finishedRequest)
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
