import Foundation
#if os(iOS)
import UIKit
import AudioToolbox
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
        #if os(iOS)
        AudioServicesPlaySystemSound(1104) // Subtle low beep
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }

    public func playPhaseTransition() {
        guard shouldPlayAudio else { return }
        #if os(iOS)
        AudioServicesPlaySystemSound(1052) // Different tone
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.directionUp)
        #endif
    }

    public func playCompletion() {
        guard shouldPlayAudio else { return }
        #if os(iOS)
        AudioServicesPlaySystemSound(1025) // Completion sound
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
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
