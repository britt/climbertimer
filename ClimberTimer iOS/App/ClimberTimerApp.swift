import SwiftUI
import SwiftData

@main
struct ClimberTimerApp: App {
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
            HomeView(presetStore: presetStore)
        }
        .modelContainer(modelContainer)
    }
}
