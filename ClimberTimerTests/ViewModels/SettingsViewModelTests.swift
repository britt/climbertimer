import XCTest
@testable import ClimberTimer

final class SettingsViewModelTests: XCTestCase {

    func test_default_settings_all_enabled() {
        let viewModel = SettingsViewModel()

        XCTAssertTrue(viewModel.audioEnabled)
        XCTAssertTrue(viewModel.visualEnabled)
        XCTAssertTrue(viewModel.hapticsEnabled)
    }

    func test_to_feedback_settings() {
        let viewModel = SettingsViewModel()
        viewModel.audioEnabled = false

        let settings = viewModel.toFeedbackSettings()

        XCTAssertFalse(settings.audioEnabled)
        XCTAssertTrue(settings.visualEnabled)
        XCTAssertTrue(settings.hapticsEnabled)
    }
}
