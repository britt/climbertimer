import XCTest
@testable import ClimberTimer

final class TimerPhaseTests: XCTestCase {

    func test_phase_display_names() {
        XCTAssertEqual(TimerPhase.work.displayName, "WORK")
        XCTAssertEqual(TimerPhase.rest.displayName, "REST")
        XCTAssertEqual(TimerPhase.finished.displayName, "DONE")
    }

    func test_phase_colors_matchAppColors() {
        // Color names must match AppColors names for Live Activity widget
        XCTAssertEqual(TimerPhase.countdown.colorName, "rust")
        XCTAssertEqual(TimerPhase.work.colorName, "woodlandGreen")
        XCTAssertEqual(TimerPhase.rest.colorName, "slate")
        XCTAssertEqual(TimerPhase.finished.colorName, "granite")
    }
}
