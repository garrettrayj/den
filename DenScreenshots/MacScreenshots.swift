//
//  MacScreenshots.swift
//  MacScreenshots
//
//  Created by Garrett Johnson on 7/30/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import XCTest

class MacScreenshots: ScreenshotTestCase {
    override var targetIdiom: UIUserInterfaceIdiom { .mac }

    func refreshPage(pageName: String) {
        let windowsQuery = app.windows["SceneWindow"].windows
        windowsQuery.tables.buttons["\(pageName), 0"].tap()
        windowsQuery.navigationBars[pageName].buttons["refresh"].tap()
    }

    func refreshAllPages() {
        demoPages.forEach { pageName in
            refreshPage(pageName: pageName)
        }
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
