import Foundation
import Combine
import UIKit

@Observable
public final class BackgroundTimerCoordinator {
    public private(set) var timer: IntervalTimer?
    public private(set) var schedule: PhaseSchedule?

    private let persistence: TimerPersistence
    private let notificationManager: NotificationManager
    private let liveActivityManager: LiveActivityManager

    private var phaseObserver: AnyCancellable?
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?

    public init(
        userDefaults: UserDefaults = .standard,
        notificationManager: NotificationManager = NotificationManager(),
        liveActivityManager: LiveActivityManager = LiveActivityManager()
    ) {
        self.persistence = TimerPersistence(userDefaults: userDefaults)
        self.notificationManager = notificationManager
        self.liveActivityManager = liveActivityManager

        setupLifecycleObservers()
    }

    deinit {
        if let backgroundObserver = backgroundObserver {
            NotificationCenter.default.removeObserver(backgroundObserver)
        }
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
    }

    // MARK: - Public API

    public func startTimer(with interval: Interval) async {
        let startTime = Date()
        let newSchedule = PhaseSchedule(interval: interval, startTime: startTime)
        let newTimer = IntervalTimer(interval: interval)

        self.schedule = newSchedule
        self.timer = newTimer

        // Start the timer
        newTimer.start()

        // Persist state
        persistence.save(schedule: newSchedule, isPaused: false, pausedAt: nil)

        // Request notification permission if needed, then schedule
        await notificationManager.checkAuthorizationStatus()
        if !notificationManager.isAuthorized {
            _ = await notificationManager.requestAuthorization()
        }
        await notificationManager.scheduleNotifications(for: newSchedule)

        // Start Live Activity
        await liveActivityManager.startActivity(
            schedule: newSchedule,
            currentPhase: .countdown,
            currentRep: 1,
            timeRemaining: 3
        )

        // Setup phase change observation
        setupPhaseObserver()
    }

    public func pauseTimer() async {
        guard let timer = timer, let schedule = schedule else { return }

        timer.pause()

        // Persist paused state
        persistence.save(schedule: schedule, isPaused: true, pausedAt: Date())

        // Cancel notifications
        await notificationManager.cancelAllTimerNotifications()
    }

    public func resumeTimer() async {
        guard let timer = timer, let schedule = schedule else { return }

        timer.resume()

        // Persist running state
        persistence.save(schedule: schedule, isPaused: false, pausedAt: nil)

        // Reschedule notifications from current state
        await rescheduleNotificationsFromCurrentState()
    }

    public func resetTimer() async {
        guard timer != nil else { return }

        timer?.reset()

        // Clear persistence
        persistence.clear()

        // Cancel notifications
        await notificationManager.cancelAllTimerNotifications()

        // End Live Activity
        await liveActivityManager.endActivity()

        // Clear state
        self.timer = nil
        self.schedule = nil
    }

    public func restoreFromBackground() async {
        guard let state = persistence.load() else { return }

        let now = Date()

        // Check if timer has finished
        if state.schedule.isFinished(at: now) {
            // Timer completed in background - show finished state
            await handleTimerCompletedInBackground(schedule: state.schedule)
            return
        }

        // Check if timer was paused
        if state.isPaused {
            await restorePausedTimer(state: state)
            return
        }

        // Timer was running - restore to current position
        await restoreRunningTimer(state: state, currentTime: now)
    }

    // MARK: - Private Methods

    private func setupLifecycleObservers() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppWillResignActive()
        }

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.handleAppDidBecomeActive()
            }
        }
    }

    private func handleAppWillResignActive() {
        guard let schedule = schedule, let timer = timer else { return }

        // Save current state
        if timer.isRunning {
            persistence.save(schedule: schedule, isPaused: false, pausedAt: nil)
        } else {
            persistence.save(schedule: schedule, isPaused: true, pausedAt: Date())
        }
    }

    private func handleAppDidBecomeActive() async {
        await restoreFromBackground()
    }

    private func setupPhaseObserver() {
        // Observe phase changes to update Live Activity
        phaseObserver?.cancel()

        var lastPhase: TimerPhase?
        var lastRep: Int?

        phaseObserver = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self,
                      let timer = self.timer,
                      let _ = self.schedule else { return }

                // Check for phase change
                if timer.currentPhase != lastPhase || timer.currentRep != lastRep {
                    lastPhase = timer.currentPhase
                    lastRep = timer.currentRep

                    Task {
                        await self.liveActivityManager.updateActivity(
                            phase: timer.currentPhase,
                            rep: timer.currentRep,
                            totalReps: timer.totalReps,
                            timeRemaining: timer.timeRemaining
                        )
                    }

                    // Check if finished
                    if timer.currentPhase == .finished {
                        Task {
                            await self.handleTimerCompleted()
                        }
                    }
                }
            }
    }

    private func handleTimerCompleted() async {
        persistence.clear()
        await liveActivityManager.endActivity()
        phaseObserver?.cancel()
    }

    private func handleTimerCompletedInBackground(schedule: PhaseSchedule) async {
        persistence.clear()

        // Create a finished timer for display
        let interval = Interval(
            name: schedule.intervalName,
            workDuration: schedule.phases.first { $0.phase == .work }?.duration ?? 7,
            restDuration: schedule.phases.first { $0.phase == .rest }?.duration ?? 3,
            repetitions: schedule.totalReps
        )
        let newTimer = IntervalTimer(interval: interval)

        // Simulate to finished state
        while newTimer.currentPhase != .finished {
            newTimer.simulateTick(seconds: 100)
        }

        self.timer = newTimer
        self.schedule = nil

        await liveActivityManager.endActivity()
    }

    private func restorePausedTimer(state: PersistedTimerState) async {
        // Create timer with interval from schedule
        let interval = Interval(
            name: state.schedule.intervalName,
            workDuration: state.schedule.phases.first { $0.phase == .work }?.duration ?? 7,
            restDuration: state.schedule.phases.first { $0.phase == .rest }?.duration ?? 3,
            repetitions: state.schedule.totalReps
        )

        let newTimer = IntervalTimer(interval: interval)

        // Simulate to paused position
        if let pausedAt = state.pausedAt,
           let _ = state.schedule.currentPhase(at: pausedAt) {
            // Calculate elapsed time to reach this point
            let elapsedFromStart = pausedAt.timeIntervalSince(state.schedule.startTime)
            newTimer.simulateTick(seconds: elapsedFromStart)
        }

        self.timer = newTimer
        self.schedule = state.schedule

        // Update Live Activity to paused state
        await liveActivityManager.updateActivity(
            phase: newTimer.currentPhase,
            rep: newTimer.currentRep,
            totalReps: newTimer.totalReps,
            timeRemaining: newTimer.timeRemaining
        )
    }

    private func restoreRunningTimer(state: PersistedTimerState, currentTime: Date) async {
        guard let _ = state.schedule.currentPhase(at: currentTime),
              let _ = state.schedule.timeRemaining(at: currentTime) else {
            return
        }

        // Create timer with interval from schedule
        let interval = Interval(
            name: state.schedule.intervalName,
            workDuration: state.schedule.phases.first { $0.phase == .work }?.duration ?? 7,
            restDuration: state.schedule.phases.first { $0.phase == .rest }?.duration ?? 3,
            repetitions: state.schedule.totalReps
        )

        let newTimer = IntervalTimer(interval: interval)

        // Simulate to exact current position
        let elapsedFromStart = currentTime.timeIntervalSince(state.schedule.startTime)
        newTimer.simulateTick(seconds: elapsedFromStart)

        // Start the timer running
        newTimer.start()

        self.timer = newTimer
        self.schedule = state.schedule

        // Update Live Activity
        await liveActivityManager.updateActivity(
            phase: newTimer.currentPhase,
            rep: newTimer.currentRep,
            totalReps: newTimer.totalReps,
            timeRemaining: newTimer.timeRemaining
        )

        setupPhaseObserver()
    }

    private func rescheduleNotificationsFromCurrentState() async {
        // For simplicity, we don't reschedule mid-timer
        // Notifications are scheduled once at start
    }
}
