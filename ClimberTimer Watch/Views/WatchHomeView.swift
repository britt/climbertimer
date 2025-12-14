import SwiftUI
import SwiftData

struct WatchHomeView: View {
    @State private var workDuration: Double = 7
    @State private var restDuration: Double = 3
    @State private var repetitions: Double = 6
    @State private var showingTimer = false

    let presetStore: PresetStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Work Duration
                    HStack {
                        Text("Work")
                        Spacer()
                        Text("\(Int(workDuration))s")
                            .foregroundStyle(.green)
                    }
                    .focusable()
                    .digitalCrownRotation($workDuration, from: 1, through: 60, by: 1)

                    // Rest Duration
                    HStack {
                        Text("Rest")
                        Spacer()
                        Text("\(Int(restDuration))s")
                            .foregroundStyle(.blue)
                    }
                    .focusable()
                    .digitalCrownRotation($restDuration, from: 1, through: 60, by: 1)

                    // Reps
                    HStack {
                        Text("Reps")
                        Spacer()
                        Text("\(Int(repetitions))")
                    }
                    .focusable()
                    .digitalCrownRotation($repetitions, from: 1, through: 20, by: 1)

                    // Start Button
                    Button(action: { showingTimer = true }) {
                        Text("START")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    // Presets Link
                    NavigationLink("Presets") {
                        WatchPresetsView(presetStore: presetStore) { preset in
                            workDuration = preset.workDuration
                            restDuration = preset.restDuration
                            repetitions = Double(preset.repetitions)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Timer")
            .fullScreenCover(isPresented: $showingTimer) {
                WatchActiveTimerView(
                    interval: Interval(
                        name: "",
                        workDuration: workDuration,
                        restDuration: restDuration,
                        repetitions: Int(repetitions)
                    )
                )
            }
        }
        .onAppear {
            loadLastUsed()
        }
    }

    private func loadLastUsed() {
        if let lastUsed = presetStore.loadLastUsed() {
            workDuration = lastUsed.workDuration
            restDuration = lastUsed.restDuration
            repetitions = Double(lastUsed.repetitions)
        }
    }
}
