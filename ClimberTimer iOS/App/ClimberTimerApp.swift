import SwiftUI
import SwiftData

@main
struct ClimberTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let modelContainer: ModelContainer
    @State private var presetStore: PresetStore

    init() {
        // Reset UserDefaults for UI testing if launch argument is present
        if CommandLine.arguments.contains("-resetUserDefaults") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }

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
                .tint(AppColors.granite)
        }
        .modelContainer(modelContainer)
    }
}
