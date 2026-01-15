import XCTest
@testable import ClimberTimer

final class SavePresetSheetTests: XCTestCase {

    func test_initialState_hasEmptyPresetName() {
        // Given/When
        let viewModel = SavePresetSheetViewModel()

        // Then
        XCTAssertEqual(viewModel.presetName, "")
    }
}
