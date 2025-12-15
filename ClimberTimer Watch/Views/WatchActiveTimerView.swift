import SwiftUI
import WatchKit

struct WatchActiveTimerView: View {
    @State private var timer: IntervalTimer
    @State private var flashOpacity: Double = 1.0
    @Environment(\.dismiss) private var dismiss

    init(interval: Interval) {
        _timer = State(initialValue: IntervalTimer(interval: interval))
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
                .opacity(flashOpacity)

            VStack {
                Text(timer.currentPhase.displayName)
                    .font(Typography.caption)

                Text(TimeFormatting.format(timer.timeRemaining))
                    .font(Typography.timerSmall)

                Text("\(timer.currentRep)/\(timer.totalReps)")
                    .font(Typography.caption)
            }
            .foregroundColor(.white)
        }
        .onAppear {
            timer.start()
        }
        .onTapGesture {
            if timer.isRunning {
                timer.pause()
            } else if timer.currentPhase == .finished {
                dismiss()
            } else {
                timer.resume()
            }
        }
        .onChange(of: timer.countdownWarningSecond) { _, newValue in
            if newValue != nil {
                WKInterfaceDevice.current().play(.click)
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
                WKInterfaceDevice.current().play(.success)
            } else {
                WKInterfaceDevice.current().play(.start)
            }
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
}
