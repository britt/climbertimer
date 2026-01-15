import XCTest
@testable import ClimberTimer

final class SavePresetSheetTests: XCTestCase {

    func test_initialState_hasEmptyPresetName() {
        // Given/When
        let viewModel = SavePresetSheetViewModel()

        // Then
        XCTAssertEqual(viewModel.presetName, "")
    }

    func test_canSave_returnsFalse_whenPresetNameIsEmpty() {
        // Given
        let viewModel = SavePresetSheetViewModel()

        // When
        viewModel.presetName = ""

        // Then
        XCTAssertFalse(viewModel.canSave)
    }

    func test_canSave_returnsFalse_whenPresetNameIsWhitespaceOnly() {
        // Given
        let viewModel = SavePresetSheetViewModel()

        // When
        viewModel.presetName = "   "

        // Then
        XCTAssertFalse(viewModel.canSave)
    }

    func test_canSave_returnsTrue_whenPresetNameHasContent() {
        // Given
        let viewModel = SavePresetSheetViewModel()

        // When
        viewModel.presetName = "My Preset"

        // Then
        XCTAssertTrue(viewModel.canSave)
    }
}
