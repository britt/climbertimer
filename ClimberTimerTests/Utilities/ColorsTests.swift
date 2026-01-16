import XCTest
import SwiftUI
@testable import ClimberTimer

final class ColorsTests: XCTestCase {

    // MARK: - Color Name Mapping Tests

    func test_colorForName_rust_returnsRustColor() {
        let color = AppColors.color(forName: "rust")
        XCTAssertEqual(color, AppColors.rust)
    }

    func test_colorForName_woodlandGreen_returnsWoodlandGreenColor() {
        let color = AppColors.color(forName: "woodlandGreen")
        XCTAssertEqual(color, AppColors.woodlandGreen)
    }

    func test_colorForName_slate_returnsSlateColor() {
        let color = AppColors.color(forName: "slate")
        XCTAssertEqual(color, AppColors.slate)
    }

    func test_colorForName_granite_returnsGraniteColor() {
        let color = AppColors.color(forName: "granite")
        XCTAssertEqual(color, AppColors.granite)
    }

    func test_colorForName_unknown_returnsPrimaryColor() {
        let color = AppColors.color(forName: "unknownColor")
        XCTAssertEqual(color, Color.primary)
    }
}
