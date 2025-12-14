import SwiftUI
import SwiftData

struct TimerSetupView: View {
    @State private var viewModel: HomeViewModel
    @State private var presetsViewModel: PresetsViewModel
    @Bindable var settingsViewModel: SettingsViewModel
    @State private var showingTimer = false
    @State private var showingSettings = false
    @State private var showingSavePreset = false
    @State private var presetName = ""
    @Environment(\.dismiss) private var dismiss

    private let presetStore: PresetStore

    init(presetStore: PresetStore, settingsViewModel: SettingsViewModel, initialInterval: Interval? = nil) {
        self.presetStore = presetStore
        self.settingsViewModel = settingsViewModel
        _viewModel = State(initialValue: HomeViewModel(presetStore: presetStore))
        _presetsViewModel = State(initialValue: PresetsViewModel(presetStore: presetStore))

        // Load initial interval if provided
        if let interval = initialInterval {
            _viewModel = State(initialValue: {
                let vm = HomeViewModel(presetStore: presetStore)
                vm.loadPreset(interval)
                return vm
            }())
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            // Work Duration
            VStack {
                Text("WORK")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Button("-") { if viewModel.workDuration > 1 { viewModel.workDuration -= 1 } }
                        .buttonStyle(.bordered)
                    Text("\(Int(viewModel.workDuration))s")
                        .font(.title)
                        .frame(minWidth: 60)
                    Button("+") { if viewModel.workDuration < 60 { viewModel.workDuration += 1 } }
                        .buttonStyle(.bordered)
                }
            }

            // Rest Duration
            VStack {
                Text("REST")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Button("-") { if viewModel.restDuration > 1 { viewModel.restDuration -= 1 } }
                        .buttonStyle(.bordered)
                    Text("\(Int(viewModel.restDuration))s")
                        .font(.title)
                        .frame(minWidth: 60)
                    Button("+") { if viewModel.restDuration < 60 { viewModel.restDuration += 1 } }
                        .buttonStyle(.bordered)
                }
            }

            // Repetitions
            VStack {
                Text("REPS")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Button("-") { if viewModel.repetitions > 1 { viewModel.repetitions -= 1 } }
                        .buttonStyle(.bordered)
                    Text("\(viewModel.repetitions)")
                        .font(.title)
                        .frame(minWidth: 60)
                    Button("+") { if viewModel.repetitions < 20 { viewModel.repetitions += 1 } }
                        .buttonStyle(.bordered)
                }
            }

            Spacer()

            // Save as Preset Button
            Button("Save as Preset") {
                showingSavePreset = true
            }
            .buttonStyle(.bordered)

            // Start Button
            Button(action: {
                viewModel.saveAsLastUsed()
                showingTimer = true
            }) {
                Text("START")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
        }
        .padding()
        .navigationTitle("Timer Setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .fullScreenCover(isPresented: $showingTimer) {
            ActiveTimerView(
                interval: viewModel.createInterval(),
                settings: settingsViewModel.toFeedbackSettings()
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: settingsViewModel)
        }
        .alert("Save Preset", isPresented: $showingSavePreset) {
            TextField("Preset Name", text: $presetName)
            Button("Cancel", role: .cancel) { presetName = "" }
            Button("Save") {
                presetsViewModel.saveCurrentAsPreset(
                    name: presetName,
                    workDuration: viewModel.workDuration,
                    restDuration: viewModel.restDuration,
                    repetitions: viewModel.repetitions
                )
                presetName = ""
            }
        }
    }
}
