import SwiftUI
import SwiftData

struct HomeView: View {
    @Bindable var presetStore: PresetStore
    @State private var presetsViewModel: PresetsViewModel
    @State private var settingsViewModel = SettingsViewModel()
    @State private var showingSettings = false
    @State private var showingNewTimer = false
    @State private var navigationPath = NavigationPath()
    @State private var isEditing = false

    init(presetStore: PresetStore) {
        self.presetStore = presetStore
        _presetsViewModel = State(initialValue: PresetsViewModel(presetStore: presetStore))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                // Last Used Section
                if let lastUsed = presetStore.lastUsed {
                    Section("Last Used") {
                        Button(action: {
                            navigationPath.append(lastUsed)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(lastUsed.name.isEmpty ? "Quick Start" : lastUsed.name)
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
                Section {
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
                } header: {
                    HStack {
                        Text("Presets")
                        Spacer()
                        if !presetsViewModel.presets.isEmpty {
                            Button(isEditing ? "Done" : "Edit") {
                                withAnimation {
                                    isEditing.toggle()
                                }
                            }
                            .font(.subheadline)
                            .textCase(nil)
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .navigationTitle("ClimberTimer")
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 16) {
                    Button {
                        showingNewTimer = true
                    } label: {
                        Text("New Timer")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }

                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.title2)
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .padding()
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
            .navigationDestination(isPresented: $showingNewTimer) {
                TimerSetupView(
                    presetStore: presetStore,
                    settingsViewModel: settingsViewModel,
                    initialInterval: nil
                )
            }
            .onAppear {
                presetsViewModel.loadPresets()
            }
        }
    }
}
