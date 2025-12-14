import XCTest
@testable import ClimberTimer

final class TimerPhaseTests: XCTestCase {

    func test_phase_display_names() {
        XCTAssertEqual(TimerPhase.work.displayName, "WORK")
        XCTAssertEqual(TimerPhase.rest.displayName, "REST")
        XCTAssertEqual(TimerPhase.finished.displayName, "DONE")
    }

    func test_phase_colors() {
        XCTAssertEqual(TimerPhase.work.colorName, "green")
        XCTAssertEqual(TimerPhase.rest.colorName, "blue")
        XCTAssertEqual(TimerPhase.finished.colorName, "gray")
    }
}
