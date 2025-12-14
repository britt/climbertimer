import XCTest
@testable import ClimberTimer

final class FeedbackSettingsTests: XCTestCase {

    func test_default_settings_all_enabled() {
        let settings = FeedbackSettings()

        XCTAssertTrue(settings.audioEnabled)
        XCTAssertTrue(settings.visualEnabled)
        XCTAssertTrue(settings.hapticsEnabled)
    }

    func test_settings_can_be_modified() {
        var settings = FeedbackSettings()

        settings.audioEnabled = false
        settings.hapticsEnabled = false

        XCTAssertFalse(settings.audioEnabled)
        XCTAssertTrue(settings.visualEnabled)
        XCTAssertFalse(settings.hapticsEnabled)
    }

    func test_settings_codable() throws {
        let settings = FeedbackSettings(
            audioEnabled: false,
            visualEnabled: true,
            hapticsEnabled: false
        )

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(FeedbackSettings.self, from: data)

        XCTAssertEqual(settings.audioEnabled, decoded.audioEnabled)
        XCTAssertEqual(settings.visualEnabled, decoded.visualEnabled)
        XCTAssertEqual(settings.hapticsEnabled, decoded.hapticsEnabled)
    }
}
