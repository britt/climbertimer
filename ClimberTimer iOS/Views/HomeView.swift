import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var presetsViewModel: PresetsViewModel
    @State private var settingsViewModel = SettingsViewModel()
    @State private var showingSettings = false
    @State private var navigationPath = NavigationPath()

    private let presetStore: PresetStore

    init(presetStore: PresetStore) {
        self.presetStore = presetStore
        _presetsViewModel = State(initialValue: PresetsViewModel(presetStore: presetStore))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                // Last Used Section
                if let lastUsed = presetStore.loadLastUsed() {
                    Section("Last Used") {
                        Button(action: {
                            navigationPath.append(lastUsed)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Quick Start")
                                        .font(.headline)
                                    Text(lastUsed.summary)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.green)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Presets Section
                Section("Presets") {
                    if presetsViewModel.presets.isEmpty {
                        Text("No presets saved")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(presetsViewModel.presets, id: \.id) { preset in
                            Button(action: {
                                navigationPath.append(preset)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.name)
                                        .font(.headline)
                                    Text(preset.summary)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: presetsViewModel.deletePreset)
                    }
                }
            }
            .navigationTitle("ClimberTimer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                if !presetsViewModel.presets.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                }
            }
            .navigationDestination(for: Interval.self) { interval in
                TimerSetupView(
                    presetStore: presetStore,
                    settingsViewModel: settingsViewModel,
                    initialInterval: interval
                )
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: settingsViewModel)
            }
            .onAppear {
                presetsViewModel.loadPresets()
            }
        }
    }
}
