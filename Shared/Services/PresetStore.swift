import Foundation
import SwiftData

// Codable struct for UserDefaults storage
private struct LastUsedInterval: Codable {
    let name: String
    let workDuration: TimeInterval
    let restDuration: TimeInterval
    let repetitions: Int
}

@Observable
public class PresetStore {
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext
    private let userDefaults: UserDefaults
    private static let lastUsedKey = "lastUsedInterval"

    public private(set) var lastUsed: Interval?

    public init(modelContainer: ModelContainer, userDefaults: UserDefaults = .standard) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
        self.userDefaults = userDefaults
        // Load from UserDefaults on init, or use default quick start
        self.lastUsed = Self.loadFromDefaults(userDefaults: userDefaults) ?? Interval.defaultQuickStart
    }

    private static func loadFromDefaults(userDefaults: UserDefaults) -> Interval? {
        guard let data = userDefaults.data(forKey: lastUsedKey),
              let lastUsedData = try? JSONDecoder().decode(LastUsedInterval.self, from: data) else {
            return nil
        }
        return Interval(
            name: lastUsedData.name,
            workDuration: lastUsedData.workDuration,
            restDuration: lastUsedData.restDuration,
            repetitions: lastUsedData.repetitions
        )
    }

    // MARK: - Presets (SwiftData)

    public func savePreset(_ interval: Interval) throws {
        modelContext.insert(interval)
        try modelContext.save()
    }

    public func fetchPresets() -> [Interval] {
        let descriptor = FetchDescriptor<Interval>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    public func deletePreset(_ interval: Interval) throws {
        // If deleting the last used preset, reset to default
        if let lastUsed = lastUsed,
           lastUsed.name == interval.name &&
           lastUsed.workDuration == interval.workDuration &&
           lastUsed.restDuration == interval.restDuration &&
           lastUsed.repetitions == interval.repetitions {
            resetLastUsedToDefault()
        }
        modelContext.delete(interval)
        try modelContext.save()
    }

    public func resetLastUsedToDefault() {
        userDefaults.removeObject(forKey: Self.lastUsedKey)
        lastUsed = Interval.defaultQuickStart
    }

    // MARK: - Last Used (UserDefaults)

    public func saveLastUsed(_ interval: Interval) {
        let lastUsedData = LastUsedInterval(
            name: interval.name,
            workDuration: interval.workDuration,
            restDuration: interval.restDuration,
            repetitions: interval.repetitions
        )
        if let data = try? JSONEncoder().encode(lastUsedData) {
            userDefaults.set(data, forKey: Self.lastUsedKey)
        }
        // Update stored property to trigger @Observable update
        lastUsed = Interval(
            name: interval.name,
            workDuration: interval.workDuration,
            restDuration: interval.restDuration,
            repetitions: interval.repetitions
        )
    }

    public func loadLastUsed() -> Interval? {
        return lastUsed
    }
}
