import Foundation

public struct FeedbackSettings: Codable, Equatable {
    public var audioEnabled: Bool
    public var visualEnabled: Bool
    public var hapticsEnabled: Bool

    public init(
        audioEnabled: Bool = true,
        visualEnabled: Bool = true,
        hapticsEnabled: Bool = true
    ) {
        self.audioEnabled = audioEnabled
        self.visualEnabled = visualEnabled
        self.hapticsEnabled = hapticsEnabled
    }
}
