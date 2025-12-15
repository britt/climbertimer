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
        ZStack {
            // Background color based on phase
            backgroundColor
                .ignoresSafeArea()
                .opacity(flashOpacity)

            VStack(spacing: 24) {
                // Phase indicator
                Text(timer.currentPhase.displayName)
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.8))

                // Time remaining
                Text(TimeFormatting.format(timer.timeRemaining))
                    .font(.system(size: 96, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                // Rep counter
                Text("Rep \(timer.currentRep) of \(timer.totalReps)")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                // Controls
                HStack(spacing: 32) {
                    // Reset button
                    Button(action: { timer.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }

                    // Play/Pause button
                    Button(action: toggleTimer) {
                        Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.white.opacity(0.3))
                            .clipShape(Circle())
                    }

                    // Close button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
        }
        .onAppear {
            timer.start()
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
        case .countdown: return .orange
        case .work: return .green
        case .rest: return .blue
        case .finished: return .gray
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
