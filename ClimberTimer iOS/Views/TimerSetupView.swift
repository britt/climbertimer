import SwiftUI
import SwiftData

struct TimerSetupView: View {
    @State private var viewModel: HomeViewModel
    @State private var presetsViewModel: PresetsViewModel
    @Bindable var settingsViewModel: SettingsViewModel
    @State private var showingTimer = false
    @State private var showingSavePreset = false
    @State private var showingWorkPicker = false
    @State private var showingRestPicker = false
    @State private var showingRepsPicker = false
    @State private var presetName = ""
    @State private var hasLoadedInitialInterval = false
    @State private var savedPresetName: String?
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
                    .font(.custom("AvenirNextCondensed-Bold", size: 21))
                    .foregroundStyle(AppColors.granite)
                Button {
                    showingWorkPicker = true
                } label: {
                    Text(formatDuration(viewModel.workDuration))
                        .font(.custom("Menlo-Bold", size: 35))
                        .foregroundStyle(AppColors.granite)
                        .frame(minWidth: 120)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(AppColors.granite.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(.borderless)
            }

            // Rest Duration
            VStack {
                Text("REST")
                    .font(.custom("AvenirNextCondensed-Bold", size: 21))
                    .foregroundStyle(AppColors.granite)
                Button {
                    showingRestPicker = true
                } label: {
                    Text(formatDuration(viewModel.restDuration))
                        .font(.custom("Menlo-Bold", size: 35))
                        .foregroundStyle(AppColors.granite)
                        .frame(minWidth: 120)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(AppColors.granite.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(.borderless)
            }

            // Repetitions
            VStack {
                Text("REPS")
                    .font(.custom("AvenirNextCondensed-Bold", size: 21))
                    .foregroundStyle(AppColors.granite)
                Button {
                    showingRepsPicker = true
                } label: {
                    Text("\(viewModel.repetitions)")
                        .font(.custom("Menlo-Bold", size: 35))
                        .foregroundStyle(AppColors.granite)
                        .frame(minWidth: 120)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(AppColors.granite.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(.borderless)
            }

            Spacer()

            // Save as Preset Button
            Button("Save as Preset") {
                showingSavePreset = true
            }
            .font(.custom("AvenirNext-DemiBold", size: 21))
            .foregroundStyle(AppColors.granite)
            .buttonStyle(.borderless)

            // Start Button
            Button(action: {
                viewModel.saveAsLastUsed()
                showingTimer = true
            }) {
                Text("START")
                    .font(.custom("AvenirNextCondensed-Bold", size: 28))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.woodlandGreen.opacity(0.75))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .offset(x: -500)
                AppColors.tan.opacity(0.85)
            }
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.body)
                            Text("Back")
                                .font(.custom("AvenirNext-Regular", size: 17))
                        }
                        .foregroundStyle(AppColors.granite)
                    }

                    Spacer()

                    Text(savedPresetName ?? (initialInterval?.name.isEmpty == false ? initialInterval!.name : "New Timer"))
                        .font(.custom("AvenirNextCondensed-Bold", size: 20))
                        .foregroundStyle(AppColors.darkBrown)

                    Spacer()

                    // Invisible spacer to balance the back button
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.body)
                        Text("Back")
                            .font(.custom("AvenirNext-Regular", size: 17))
                    }
                    .opacity(0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Rectangle()
                    .fill(AppColors.granite.opacity(0.3))
                    .frame(height: 1)
            }
        }
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
                let name = presetName
                presetsViewModel.saveCurrentAsPreset(
                    name: name,
                    workDuration: viewModel.workDuration,
                    restDuration: viewModel.restDuration,
                    repetitions: viewModel.repetitions
                )
                viewModel.presetName = name
                savedPresetName = name
                presetName = ""
            }
        }
        .sheet(isPresented: $showingWorkPicker) {
            DurationPickerView(title: "Work Duration", duration: $viewModel.workDuration)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingRestPicker) {
            DurationPickerView(title: "Rest Duration", duration: $viewModel.restDuration)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingRepsPicker) {
            RepsPickerView(reps: $viewModel.repetitions)
                .presentationDetents([.medium])
        }
        .onAppear {
            // Load initial interval when view appears (not in init, due to SwiftUI state issues)
            if !hasLoadedInitialInterval, let interval = initialInterval {
                viewModel.loadPreset(interval)
                hasLoadedInitialInterval = true
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }
}
