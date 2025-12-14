import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Feedback") {
                    Toggle("Audio", isOn: $viewModel.audioEnabled)
                    Toggle("Visual", isOn: $viewModel.visualEnabled)
                    Toggle("Haptics", isOn: $viewModel.hapticsEnabled)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
