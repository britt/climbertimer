import SwiftUI

struct PresetsListView: View {
    @Bindable var viewModel: PresetsViewModel
    @Environment(\.dismiss) private var dismiss

    let onSelect: (Interval) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.presets, id: \.id) { preset in
                    Button(action: {
                        onSelect(preset)
                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                                .font(.headline)
                            Text(preset.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: viewModel.deletePreset)
            }
            .navigationTitle("Presets")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .overlay {
                if viewModel.presets.isEmpty {
                    ContentUnavailableView(
                        "No Presets",
                        systemImage: "clock.badge.questionmark",
                        description: Text("Save your favorite intervals as presets")
                    )
                }
            }
        }
        .onAppear {
            viewModel.loadPresets()
        }
    }
}
