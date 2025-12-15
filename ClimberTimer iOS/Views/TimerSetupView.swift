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
                    .font(.custom("AvenirNext-Regular", size: 15))
                    .foregroundStyle(AppColors.granite.opacity(0.7))
                HStack {
                    Button("-") { if viewModel.workDuration > 1 { viewModel.workDuration -= 1 } }
                        .foregroundStyle(AppColors.granite)
                        .buttonStyle(.bordered)
                        .tint(AppColors.granite)
                    Text("\(Int(viewModel.workDuration))s")
                        .font(.custom("Menlo-Bold", size: 35))
                        .foregroundStyle(AppColors.granite)
                        .frame(minWidth: 80)
                    Button("+") { if viewModel.workDuration < 60 { viewModel.workDuration += 1 } }
                        .foregroundStyle(AppColors.granite)
                        .buttonStyle(.bordered)
                        .tint(AppColors.granite)
                }
            }

            // Rest Duration
            VStack {
                Text("REST")
                    .font(.custom("AvenirNext-Regular", size: 15))
                    .foregroundStyle(AppColors.granite.opacity(0.7))
                HStack {
                    Button("-") { if viewModel.restDuration > 1 { viewModel.restDuration -= 1 } }
                        .foregroundStyle(AppColors.granite)
                        .buttonStyle(.bordered)
                        .tint(AppColors.granite)
                    Text("\(Int(viewModel.restDuration))s")
                        .font(.custom("Menlo-Bold", size: 35))
                        .foregroundStyle(AppColors.granite)
                        .frame(minWidth: 80)
                    Button("+") { if viewModel.restDuration < 60 { viewModel.restDuration += 1 } }
                        .foregroundStyle(AppColors.granite)
                        .buttonStyle(.bordered)
                        .tint(AppColors.granite)
                }
            }

            // Repetitions
            VStack {
                Text("REPS")
                    .font(.custom("AvenirNext-Regular", size: 15))
                    .foregroundStyle(AppColors.granite.opacity(0.7))
                HStack {
                    Button("-") { if viewModel.repetitions > 1 { viewModel.repetitions -= 1 } }
                        .foregroundStyle(AppColors.granite)
                        .buttonStyle(.bordered)
                        .tint(AppColors.granite)
                    Text("\(viewModel.repetitions)")
                        .font(.custom("Menlo-Bold", size: 35))
                        .foregroundStyle(AppColors.granite)
                        .frame(minWidth: 80)
                    Button("+") { if viewModel.repetitions < 20 { viewModel.repetitions += 1 } }
                        .foregroundStyle(AppColors.granite)
                        .buttonStyle(.bordered)
                        .tint(AppColors.granite)
                }
            }

            Spacer()

            // Save as Preset Button
            Button("Save as Preset") {
                showingSavePreset = true
            }
            .font(.custom("AvenirNext-DemiBold", size: 21))
            .foregroundStyle(AppColors.granite)
            .buttonStyle(.bordered)
            .tint(AppColors.granite)

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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .font(.custom("AvenirNext-Regular", size: 17))
                    }
                    .foregroundStyle(AppColors.granite)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(savedPresetName ?? (initialInterval?.name.isEmpty == false ? initialInterval!.name : "New Timer"))
                    .font(.custom("AvenirNextCondensed-Bold", size: 20))
                    .foregroundStyle(AppColors.darkBrown)
            }
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColors.granite.opacity(0.3))
                .frame(height: 1)
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
                savedPresetName = name
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
