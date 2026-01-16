import XCTest
@testable import ClimberTimer

final class TimeFormattingTests: XCTestCase {

    func test_format_seconds_only() {
        XCTAssertEqual(TimeFormatting.format(7), "0:07")
        XCTAssertEqual(TimeFormatting.format(45), "0:45")
    }

    func test_format_minutes_and_seconds() {
        XCTAssertEqual(TimeFormatting.format(60), "1:00")
        XCTAssertEqual(TimeFormatting.format(90), "1:30")
        XCTAssertEqual(TimeFormatting.format(125), "2:05")
    }

    func test_format_with_decimal() {
        // ceil() is used to round up for countdown timers - ensures we don't show 0 while time remains
        XCTAssertEqual(TimeFormatting.format(7.5), "0:08")
        XCTAssertEqual(TimeFormatting.format(7.9), "0:08")
        XCTAssertEqual(TimeFormatting.format(7.1), "0:08")
        XCTAssertEqual(TimeFormatting.format(7.0), "0:07")  // Exact integer stays as-is
    }

    func test_format_zero() {
        XCTAssertEqual(TimeFormatting.format(0), "0:00")
    }
}
