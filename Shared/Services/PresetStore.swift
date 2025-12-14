import Foundation
import SwiftData

// Codable struct for UserDefaults storage
private struct LastUsedInterval: Codable {
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

    public init(modelContainer: ModelContainer, userDefaults: UserDefaults = .standard) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
        self.userDefaults = userDefaults
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
        modelContext.delete(interval)
        try modelContext.save()
    }

    // MARK: - Last Used (UserDefaults)

    public func saveLastUsed(_ interval: Interval) {
        let lastUsed = LastUsedInterval(
            workDuration: interval.workDuration,
            restDuration: interval.restDuration,
            repetitions: interval.repetitions
        )
        if let data = try? JSONEncoder().encode(lastUsed) {
            userDefaults.set(data, forKey: Self.lastUsedKey)
        }
    }

    public func loadLastUsed() -> Interval? {
        guard let data = userDefaults.data(forKey: Self.lastUsedKey),
              let lastUsed = try? JSONDecoder().decode(LastUsedInterval.self, from: data) else {
            return nil
        }
        return Interval(
            name: "",
            workDuration: lastUsed.workDuration,
            restDuration: lastUsed.restDuration,
            repetitions: lastUsed.repetitions
        )
    }
}
