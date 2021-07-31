//
//  PadScreenshots.swift
//  PadScreenshots
//
//  Created by Garrett Johnson on 7/30/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import XCTest

class PadScreenshots: ScreenshotTestCase {
    override var targetIdiom: UIUserInterfaceIdiom { .pad }

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        if UIDevice.current.userInterfaceIdiom != .phone {
            throw XCTSkip("Incompatible device type")
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func refreshPage(pageName: String) {
        app.tables.buttons["\(pageName), 0"].tap()
        app.navigationBars[pageName].buttons["Refresh"].tap()
    }

    func refreshAllPages() {
        demoPages.forEach { pageName in
            refreshPage(pageName: pageName)
        }
    }

    func gotoPageSettings(pageName: String) {
        let pageMenuButton = app.navigationBars[pageName].buttons["Page Menu"]
        expectation(for: existsPredicate, evaluatedWith: pageMenuButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        pageMenuButton.tap()
    }

    func gotoLink(_ elementIndex: Int) {
        let elementsQuery = app.scrollViews.otherElements

        elementsQuery.buttons.element(boundBy: elementIndex).tap()
        sleep(5)

        let doneButton = app.buttons["Done"]
        expectation(for: existsPredicate, evaluatedWith: doneButton, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
        doneButton.tap()
    }

    func testGetStarted() {
        takeScreenshot(named: "1-GetStarted")
    }
}
