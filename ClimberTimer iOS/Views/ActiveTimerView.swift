import SwiftUI

struct ActiveTimerView: View {
    @Environment(BackgroundTimerCoordinator.self) private var coordinator
    @State private var feedbackManager: FeedbackManager
    @State private var flashOpacity: Double = 1.0
    @Environment(\.dismiss) private var dismiss

    private let interval: Interval
    private let settings: FeedbackSettings

    init(interval: Interval, settings: FeedbackSettings) {
        self.interval = interval
        self.settings = settings
        _feedbackManager = State(initialValue: FeedbackManager(settings: settings))
    }

    private var timer: IntervalTimer? {
        coordinator.timer
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                // Background color based on phase
                backgroundColor
                    .ignoresSafeArea()
                    .opacity(flashOpacity)

                VStack(spacing: isLandscape ? 8 : 24) {
                    // Phase indicator
                    Text(timer?.currentPhase.displayName ?? "Ready")
                        .font(.custom("AvenirNextCondensed-Bold", size: isLandscape ? 44 : 68))
                        .foregroundColor(.white)

                    // Time remaining
                    Text(TimeFormatting.format(timer?.timeRemaining ?? 0))
                        .font(.custom("Menlo-Bold", size: isLandscape ? 60 : 80))
                        .foregroundColor(.white)

                    // Rep counter
                    Text("Rep \(timer?.currentRep ?? 1) of \(timer?.totalReps ?? interval.repetitions)")
                        .font(Typography.title3)
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    // Controls
                    HStack(spacing: 32) {
                        // Reset button
                        Button(action: {
                            Task {
                                await coordinator.resetTimer()
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: isLandscape ? 50 : 60, height: isLandscape ? 50 : 60)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.borderless)

                        // Play/Pause button
                        Button(action: {
                            Task {
                                await toggleTimer()
                            }
                        }) {
                            Image(systemName: (timer?.isRunning ?? false) ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: isLandscape ? 60 : 80, height: isLandscape ? 60 : 80)
                                .background(Color.white.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.borderless)

                        // Close button
                        Button(action: {
                            Task {
                                await coordinator.resetTimer()
                                dismiss()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: isLandscape ? 50 : 60, height: isLandscape ? 50 : 60)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding()
            }
        }
        .task {
            AppDelegate.orientationManager.allowAllOrientations()
            await coordinator.startTimer(with: interval)
        }
        .onDisappear {
            AppDelegate.orientationManager.lockToPortrait()
        }
        .onChange(of: timer?.countdownWarningSecond) { oldValue, newValue in
            if let second = newValue, second != oldValue {
                feedbackManager.playCountdownBeep()
                feedbackManager.triggerHaptic()
                // Flash effect
                withAnimation(.easeInOut(duration: 0.1)) {
                    flashOpacity = 0.6
                }
                withAnimation(.easeInOut(duration: 0.1).delay(0.1)) {
                    flashOpacity = 1.0
                }
            }
        }
        .onChange(of: timer?.currentPhase) { _, newPhase in
            guard let newPhase = newPhase else { return }
            if newPhase == .finished {
                feedbackManager.playCompletion()
            } else {
                feedbackManager.playPhaseTransition()
            }
            feedbackManager.triggerStrongHaptic()
        }
    }

    private var backgroundColor: Color {
        guard let phase = timer?.currentPhase else {
            return AppColors.countdown
        }
        switch phase {
        case .countdown: return AppColors.countdown
        case .work: return AppColors.work
        case .rest: return AppColors.rest
        case .finished: return AppColors.finished
        }
    }

    private func toggleTimer() async {
        guard let timer = timer else { return }

        if timer.isRunning {
            await coordinator.pauseTimer()
        } else if timer.currentPhase == .finished {
            await coordinator.resetTimer()
            await coordinator.startTimer(with: interval)
        } else {
            await coordinator.resumeTimer()
        }
    }
}
