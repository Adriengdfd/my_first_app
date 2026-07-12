import XCTest

final class SportFitnessTrackerUITests: XCTestCase {
    func testAppLaunch() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }
}