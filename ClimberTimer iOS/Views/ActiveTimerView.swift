import SwiftUI

struct ActiveTimerView: View {
    @State private var timer: IntervalTimer
    @State private var feedbackManager: FeedbackManager
    @State private var flashOpacity: Double = 1.0
    @Environment(\.dismiss) private var dismiss

    init(interval: Interval, settings: FeedbackSettings) {
        _timer = State(initialValue: IntervalTimer(interval: interval))
        _feedbackManager = State(initialValue: FeedbackManager(settings: settings))
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
                    Text(timer.currentPhase.displayName)
                        .font(.custom("AvenirNextCondensed-Bold", size: isLandscape ? 44 : 68))
                        .foregroundColor(.white)

                    // Time remaining
                    Text(TimeFormatting.format(timer.timeRemaining))
                        .font(.custom("Menlo-Bold", size: isLandscape ? 60 : 80))
                        .foregroundColor(.white)

                    // Rep counter
                    Text("Rep \(timer.currentRep) of \(timer.totalReps)")
                        .font(Typography.title3)
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    // Controls
                    HStack(spacing: 32) {
                        // Reset button
                        Button(action: { timer.reset() }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: isLandscape ? 50 : 60, height: isLandscape ? 50 : 60)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.borderless)

                        // Play/Pause button
                        Button(action: toggleTimer) {
                            Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: isLandscape ? 60 : 80, height: isLandscape ? 60 : 80)
                                .background(Color.white.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.borderless)

                        // Close button
                        Button(action: { dismiss() }) {
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
        .onAppear {
            AppDelegate.orientationManager.allowAllOrientations()
            timer.start()
        }
        .onDisappear {
            AppDelegate.orientationManager.lockToPortrait()
        }
        .onChange(of: timer.countdownWarningSecond) { oldValue, newValue in
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
        .onChange(of: timer.currentPhase) { _, newPhase in
            if newPhase == .finished {
                feedbackManager.playCompletion()
            } else {
                feedbackManager.playPhaseTransition()
            }
            feedbackManager.triggerStrongHaptic()
        }
    }

    private var backgroundColor: Color {
        switch timer.currentPhase {
        case .countdown: return AppColors.countdown
        case .work: return AppColors.work
        case .rest: return AppColors.rest
        case .finished: return AppColors.finished
        }
    }

    private func toggleTimer() {
        if timer.isRunning {
            timer.pause()
        } else if timer.currentPhase == .finished {
            timer.reset()
            timer.start()
        } else {
            timer.resume()
        }
    }
}
