import XCTest
@testable import ClimberTimer

final class OrientationManagerTests: XCTestCase {

    func test_defaultOrientation_isPortrait() {
        let manager = OrientationManager()

        XCTAssertEqual(manager.allowedOrientations, .portrait)
    }

    func test_allowAllOrientations_setsToAll() {
        let manager = OrientationManager()

        manager.allowAllOrientations()

        XCTAssertEqual(manager.allowedOrientations, .all)
    }

    func test_lockToPortrait_setsToPortrait() {
        let manager = OrientationManager()
        manager.allowAllOrientations()

        manager.lockToPortrait()

        XCTAssertEqual(manager.allowedOrientations, .portrait)
    }
}
