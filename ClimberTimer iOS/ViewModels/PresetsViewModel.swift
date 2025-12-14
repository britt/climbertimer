import Foundation

@Observable
public class PresetsViewModel {
    public var presets: [Interval] = []

    private let presetStore: PresetStore

    public init(presetStore: PresetStore) {
        self.presetStore = presetStore
        loadPresets()
    }

    public func loadPresets() {
        presets = presetStore.fetchPresets()
    }

    public func deletePreset(at offsets: IndexSet) {
        for index in offsets {
            let preset = presets[index]
            try? presetStore.deletePreset(preset)
        }
        loadPresets()
    }

    public func saveCurrentAsPreset(name: String, workDuration: TimeInterval, restDuration: TimeInterval, repetitions: Int) {
        let interval = Interval(
            name: name,
            workDuration: workDuration,
            restDuration: restDuration,
            repetitions: repetitions
        )
        try? presetStore.savePreset(interval)
        loadPresets()
    }
}
