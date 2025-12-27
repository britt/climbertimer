import XCTest
import SwiftUI
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

    func test_numberOfRows_returnsItemCount() {
        let items = [0, 1, 2, 3, 4]
        let coordinator = SilentPickerCoordinator(
            selection: .constant(0),
            items: items
        )

        let picker = UIPickerView()
        let result = coordinator.pickerView(picker, numberOfRowsInComponent: 0)

        XCTAssertEqual(result, 5)
    }

    func test_didSelectRow_updatesSelection() {
        var selectedValue = 0
        let binding = Binding(
            get: { selectedValue },
            set: { selectedValue = $0 }
        )
        let coordinator = SilentPickerCoordinator(
            selection: binding,
            items: [10, 20, 30, 40, 50]
        )

        let picker = UIPickerView()
        coordinator.pickerView(picker, didSelectRow: 2, inComponent: 0)

        XCTAssertEqual(selectedValue, 30)
    }
}
