import SwiftUI

struct WatchPresetsView: View {
    let presetStore: PresetStore
    let onSelect: (Interval) -> Void

    @State private var presets: [Interval] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(presets, id: \.id) { preset in
            Button(action: {
                onSelect(preset)
                dismiss()
            }) {
                VStack(alignment: .leading) {
                    Text(preset.name)
                        .font(.headline)
                    Text(preset.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Presets")
        .onAppear {
            presets = presetStore.fetchPresets()
        }
        .overlay {
            if presets.isEmpty {
                Text("No presets")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
