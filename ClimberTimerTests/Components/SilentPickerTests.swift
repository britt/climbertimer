import XCTest
@testable import ClimberTimer

final class SilentPickerCoordinatorTests: XCTestCase {

    func test_numberOfComponents_returnsOne() {
        let coordinator = SilentPickerCoordinator(
            selection: .constant(5),
            items: [1, 2, 3, 4, 5]
        )

        let picker = UIPickerView()
        let result = coordinator.numberOfComponents(in: picker)

        XCTAssertEqual(result, 1)
    }
}
