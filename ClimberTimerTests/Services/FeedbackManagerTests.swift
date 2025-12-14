import XCTest
@testable import ClimberTimer

final class FeedbackManagerTests: XCTestCase {

    func test_should_play_audio_respects_settings() {
        var settings = FeedbackSettings(audioEnabled: true, visualEnabled: true, hapticsEnabled: true)
        var manager = FeedbackManager(settings: settings)

        XCTAssertTrue(manager.shouldPlayAudio)

        settings.audioEnabled = false
        manager = FeedbackManager(settings: settings)

        XCTAssertFalse(manager.shouldPlayAudio)
    }

    func test_should_show_visual_respects_settings() {
        var settings = FeedbackSettings(audioEnabled: true, visualEnabled: true, hapticsEnabled: true)
        var manager = FeedbackManager(settings: settings)

        XCTAssertTrue(manager.shouldShowVisual)

        settings.visualEnabled = false
        manager = FeedbackManager(settings: settings)

        XCTAssertFalse(manager.shouldShowVisual)
    }

    func test_should_trigger_haptics_respects_settings() {
        var settings = FeedbackSettings(audioEnabled: true, visualEnabled: true, hapticsEnabled: true)
        var manager = FeedbackManager(settings: settings)

        XCTAssertTrue(manager.shouldTriggerHaptics)

        settings.hapticsEnabled = false
        manager = FeedbackManager(settings: settings)

        XCTAssertFalse(manager.shouldTriggerHaptics)
    }
}
