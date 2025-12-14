import Foundation

@Observable
public class SettingsViewModel {
    public var audioEnabled: Bool = true
    public var visualEnabled: Bool = true
    public var hapticsEnabled: Bool = true

    public init() {}

    public func toFeedbackSettings() -> FeedbackSettings {
        FeedbackSettings(
            audioEnabled: audioEnabled,
            visualEnabled: visualEnabled,
            hapticsEnabled: hapticsEnabled
        )
    }
}
