import Foundation
import AVFoundation
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

public class FeedbackManager {
    private let settings: FeedbackSettings

    public var shouldPlayAudio: Bool { settings.audioEnabled }
    public var shouldShowVisual: Bool { settings.visualEnabled }
    public var shouldTriggerHaptics: Bool { settings.hapticsEnabled }

    public init(settings: FeedbackSettings) {
        self.settings = settings
    }

    public func playCountdownBeep() {
        guard shouldPlayAudio else { return }
        AudioServicesPlaySystemSound(1057) // Standard beep
    }

    public func playPhaseTransition() {
        guard shouldPlayAudio else { return }
        AudioServicesPlaySystemSound(1052) // Different tone
    }

    public func playCompletion() {
        guard shouldPlayAudio else { return }
        AudioServicesPlaySystemSound(1025) // Completion sound
    }

    public func triggerHaptic() {
        guard shouldTriggerHaptics else { return }
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }

    public func triggerStrongHaptic() {
        guard shouldTriggerHaptics else { return }
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
}
