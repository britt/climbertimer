import XCTest
@testable import ClimberTimer

final class IntervalTests: XCTestCase {

    func test_interval_initialization_with_valid_values() {
        let interval = Interval(
            name: "Repeaters",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )

        XCTAssertEqual(interval.name, "Repeaters")
        XCTAssertEqual(interval.workDuration, 7)
        XCTAssertEqual(interval.restDuration, 3)
        XCTAssertEqual(interval.repetitions, 6)
        XCTAssertNotNil(interval.id)
        XCTAssertNotNil(interval.createdAt)
    }

    func test_interval_total_duration() {
        let interval = Interval(
            name: "Test",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )

        // 6 reps × (7s work + 3s rest) = 60s
        XCTAssertEqual(interval.totalDuration, 60)
    }

    func test_interval_summary_string() {
        let interval = Interval(
            name: "Test",
            workDuration: 7,
            restDuration: 3,
            repetitions: 6
        )

        XCTAssertEqual(interval.summary, "7s / 3s × 6")
    }
}
