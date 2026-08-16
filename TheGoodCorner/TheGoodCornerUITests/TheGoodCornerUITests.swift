import XCTest

final class TheGoodCornerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Stop immediately on failure so subsequent assertions don't run against a broken state.
        continueAfterFailure = false
    }

    /// Smoke test: the app launches into a real screen (navigation bar present) without crashing.
    /// Deliberately does not assert on network-dependent content (listings/detail), since that
    /// would make this test flaky if the local API server isn't running during evaluation.
    @MainActor
    func testAppLaunchesToListingsScreen() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.navigationBars.firstMatch.waitForExistence(timeout: 10),
            "Expected the listings navigation bar to appear after launch"
        )
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}


