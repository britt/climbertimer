import Foundation
import SwiftUI

@Observable
public class HomeViewModel {
    public var workDuration: TimeInterval = 7
    public var restDuration: TimeInterval = 3
    public var repetitions: Int = 6

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
        }
    }

    public func createInterval() -> Interval {
        Interval(
            name: "",
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
    }
}
