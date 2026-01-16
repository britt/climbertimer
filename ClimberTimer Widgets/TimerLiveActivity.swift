import ActivityKit
import SwiftUI
import WidgetKit

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner UI
            TimerLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Text(context.state.phase)
                            .font(.headline)
                            .foregroundColor(AppColors.color(forName: context.state.phaseColor))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.currentRep)/\(context.state.totalReps)")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.timerName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Text(context.state.phase.prefix(1))
                    .foregroundColor(AppColors.color(forName: context.state.phaseColor))
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                    .font(.system(.caption, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 48)
            } minimal: {
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                    .font(.system(.caption2, design: .monospaced))
                    .monospacedDigit()
            }
        }
    }
}

struct TimerLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.phase)
                    .font(.headline)
                    .foregroundColor(AppColors.color(forName: context.state.phaseColor))
                Text("Rep \(context.state.currentRep) of \(context.state.totalReps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .monospacedDigit()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
}
