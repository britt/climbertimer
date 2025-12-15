import SwiftUI
import SwiftData

struct HomeView: View {
    @Bindable var presetStore: PresetStore
    @State private var presetsViewModel: PresetsViewModel
    @State private var settingsViewModel = SettingsViewModel()
    @State private var showingSettings = false
    @State private var showingNewTimer = false
    @State private var showingLastUsedTimer = false
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
                    Section {
                        HStack {
                            Button(action: {
                                navigationPath.append(lastUsed)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(lastUsed.name.isEmpty ? "Quick Start" : lastUsed.name)
                                        .font(.custom("AvenirNextCondensed-DemiBold", size: 21))
                                        .foregroundStyle(AppColors.granite)
                                    Text(lastUsed.summary)
                                        .font(.custom("AvenirNext-Regular", size: 15))
                                        .foregroundStyle(AppColors.granite.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            Button(action: {
                                showingLastUsedTimer = true
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(AppColors.woodlandGreen)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 8)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(AppColors.granite.opacity(0.3))
                                .frame(height: 1)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    } header: {
                        Text("Last Used")
                            .font(.custom("AvenirNext-Regular", size: 15))
                            .foregroundStyle(AppColors.granite.opacity(0.7))
                    }
                }

                // Presets Section
                Section {
                    if presetsViewModel.presets.isEmpty {
                        Text("No presets saved")
                            .font(.custom("AvenirNext-Regular", size: 21))
                            .foregroundStyle(AppColors.granite)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(AppColors.granite.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    } else {
                        ForEach(presetsViewModel.presets, id: \.id) { preset in
                            Button(action: {
                                navigationPath.append(preset)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.name)
                                        .font(.custom("AvenirNextCondensed-DemiBold", size: 21))
                                        .foregroundStyle(AppColors.granite)
                                    Text(preset.summary)
                                        .font(.custom("AvenirNext-Regular", size: 15))
                                        .foregroundStyle(AppColors.granite.opacity(0.7))
                                }
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(AppColors.granite.opacity(0.3))
                                        .frame(height: 1)
                                }
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        }
                        .onDelete(perform: presetsViewModel.deletePreset)
                    }
                } header: {
                    HStack {
                        Text("Presets")
                            .font(.custom("AvenirNext-Regular", size: 15))
                            .foregroundStyle(AppColors.granite.opacity(0.7))
                        Spacer()
                        if !presetsViewModel.presets.isEmpty {
                            Button(isEditing ? "Done" : "Edit") {
                                withAnimation {
                                    isEditing.toggle()
                                }
                            }
                            .font(.custom("AvenirNext-Regular", size: 15))
                            .foregroundStyle(AppColors.granite.opacity(0.7))
                            .textCase(nil)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .padding(.top, 8)
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(AppColors.granite.opacity(0.3))
                    .frame(height: 1)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Climber Timer")
                        .font(.custom("AvenirNextCondensed-Bold", size: 20))
                        .foregroundStyle(AppColors.darkBrown)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(AppColors.granite)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    showingNewTimer = true
                } label: {
                    Text("New Timer")
                        .font(.custom("AvenirNextCondensed-Bold", size: 28))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.woodlandGreen.opacity(0.75))
                        .foregroundColor(.white)
                        .cornerRadius(12)
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
            .fullScreenCover(isPresented: $showingLastUsedTimer) {
                if let lastUsed = presetStore.lastUsed {
                    ActiveTimerView(
                        interval: lastUsed,
                        settings: settingsViewModel.toFeedbackSettings()
                    )
                }
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
            .scrollContentBackground(.hidden)
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
            .tint(AppColors.granite)
        }
        .tint(AppColors.granite)
    }
}
