import SwiftUI
import SwiftData

@main
struct ClimberTimerWatchApp: App {
    let modelContainer: ModelContainer
    @State private var presetStore: PresetStore

    init() {
        do {
            let container = try ModelContainer(for: Interval.self)
            modelContainer = container
            _presetStore = State(initialValue: PresetStore(modelContainer: container))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            WatchHomeView(presetStore: presetStore)
        }
        .modelContainer(modelContainer)
    }
}
