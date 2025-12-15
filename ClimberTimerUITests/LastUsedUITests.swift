import XCTest

final class LastUsedUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        // Reset user defaults for clean state
        app.launchArguments = ["-resetUserDefaults"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func test_last_used_updates_after_starting_timer() {
        // Initially there should be no Last Used section
        let lastUsedSection = app.staticTexts["Last Used"]
        XCTAssertFalse(lastUsedSection.exists, "Last Used should not exist initially")

        // Tap New Timer button
        let newTimerButton = app.buttons["New Timer"]
        XCTAssertTrue(newTimerButton.waitForExistence(timeout: 5))
        newTimerButton.tap()

        // We should be on Timer Setup screen
        let timerSetupTitle = app.navigationBars["Timer Setup"]
        XCTAssertTrue(timerSetupTitle.waitForExistence(timeout: 5))

        // Note the default values (7s / 3s × 6)
        // Tap START
        let startButton = app.buttons["START"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        // Timer view should appear - dismiss it
        let doneButton = app.buttons["Done"]
        if doneButton.waitForExistence(timeout: 2) {
            doneButton.tap()
        } else {
            // Try tapping anywhere to dismiss or look for close button
            let closeButton = app.buttons["xmark.circle.fill"]
            if closeButton.waitForExistence(timeout: 2) {
                closeButton.tap()
            }
        }

        // Go back to home
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.waitForExistence(timeout: 2) {
            backButton.tap()
        }

        // Now Last Used should exist with "7s / 3s × 6"
        XCTAssertTrue(lastUsedSection.waitForExistence(timeout: 5), "Last Used should exist after running timer")

        let quickStart = app.staticTexts["Quick Start"]
        XCTAssertTrue(quickStart.exists, "Quick Start label should exist")

        let summary = app.staticTexts["7s / 3s × 6"]
        XCTAssertTrue(summary.exists, "Summary should show default values")
    }

    func test_last_used_updates_with_different_values() {
        // Tap New Timer
        let newTimerButton = app.buttons["New Timer"]
        XCTAssertTrue(newTimerButton.waitForExistence(timeout: 5))
        newTimerButton.tap()

        // Increase work duration by tapping + three times (7 -> 10)
        let workPlusButton = app.buttons["+"].firstMatch
        workPlusButton.tap()
        workPlusButton.tap()
        workPlusButton.tap()

        // Tap START
        let startButton = app.buttons["START"]
        startButton.tap()

        // Dismiss timer (tap anywhere or find dismiss button)
        sleep(1)
        app.tap()

        // Go back
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.waitForExistence(timeout: 2) {
            backButton.tap()
        }

        // Check Last Used shows updated values
        let summary = app.staticTexts["10s / 3s × 6"]
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "Summary should show 10s work duration")
    }
}
