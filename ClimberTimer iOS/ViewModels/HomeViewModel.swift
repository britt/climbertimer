import Foundation
import SwiftUI

@Observable
public class HomeViewModel {
    public var workDuration: TimeInterval = 7
    public var restDuration: TimeInterval = 3
    public var repetitions: Int = 6
    public var presetName: String = ""

    private let presetStore: PresetStore

    public init(presetStore: PresetStore) {
        self.presetStore = presetStore
        loadLastUsed()
    }

    private func loadLastUsed() {
        if let lastUsed = presetStore.loadLastUsed() {
            workDuration = lastUsed.workDuration
            restDuration = lastUsed.restDuration
            repetitions = lastUsed.repetitions
            presetName = lastUsed.name
        }
    }

    public func createInterval() -> Interval {
        Interval(
            name: presetName,
            workDuration: workDuration,
            restDuration: restDuration,
            repetitions: repetitions
        )
    }

    public func saveAsLastUsed() {
        let interval = createInterval()
        presetStore.saveLastUsed(interval)
    }

    public func loadPreset(_ preset: Interval) {
        workDuration = preset.workDuration
        restDuration = preset.restDuration
        repetitions = preset.repetitions
        presetName = preset.name
    }
}
