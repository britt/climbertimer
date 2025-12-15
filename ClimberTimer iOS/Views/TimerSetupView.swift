import SwiftUI
import SwiftData

struct TimerSetupView: View {
    @State private var viewModel: HomeViewModel
    @State private var presetsViewModel: PresetsViewModel
    @Bindable var settingsViewModel: SettingsViewModel
    @State private var showingTimer = false
    @State private var showingSavePreset = false
    @State private var presetName = ""
    @State private var hasLoadedInitialInterval = false
    @Environment(\.dismiss) private var dismiss

    private let presetStore: PresetStore
    private let initialInterval: Interval?

    init(presetStore: PresetStore, settingsViewModel: SettingsViewModel, initialInterval: Interval? = nil) {
        self.presetStore = presetStore
        self.settingsViewModel = settingsViewModel
        self.initialInterval = initialInterval
        _viewModel = State(initialValue: HomeViewModel(presetStore: presetStore))
        _presetsViewModel = State(initialValue: PresetsViewModel(presetStore: presetStore))
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
        .navigationTitle(initialInterval?.name.isEmpty == false ? initialInterval!.name : "New Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showingTimer) {
            ActiveTimerView(
                interval: viewModel.createInterval(),
                settings: settingsViewModel.toFeedbackSettings()
            )
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
        .onAppear {
            // Load initial interval when view appears (not in init, due to SwiftUI state issues)
            if !hasLoadedInitialInterval, let interval = initialInterval {
                viewModel.loadPreset(interval)
                hasLoadedInitialInterval = true
            }
        }
    }
}
