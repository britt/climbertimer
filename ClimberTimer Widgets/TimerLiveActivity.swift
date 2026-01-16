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
                            .foregroundColor(phaseColor(context.state.phaseColor))
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
                    .foregroundColor(phaseColor(context.state.phaseColor))
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

    private func phaseColor(_ name: String) -> Color {
        switch name {
        case "rust": return Color(red: 0.76, green: 0.38, blue: 0.26)
        case "woodlandGreen": return Color(red: 0.35, green: 0.49, blue: 0.36)
        case "slate": return Color(red: 0.44, green: 0.50, blue: 0.56)
        case "granite": return Color(red: 0.45, green: 0.40, blue: 0.35)
        default: return .primary
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
                    .foregroundColor(phaseColor(context.state.phaseColor))
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

    private func phaseColor(_ name: String) -> Color {
        switch name {
        case "rust": return Color(red: 0.76, green: 0.38, blue: 0.26)
        case "woodlandGreen": return Color(red: 0.35, green: 0.49, blue: 0.36)
        case "slate": return Color(red: 0.44, green: 0.50, blue: 0.56)
        case "granite": return Color(red: 0.45, green: 0.40, blue: 0.35)
        default: return .primary
        }
    }
}
