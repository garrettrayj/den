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

    func testScreenshots() {
        // Page list
        app.buttons["load-demo-button"].tap()
        // Refresh all pages
        /*
        let profileRefreshButton = app.buttons.matching(identifier: "profile-refresh-button").firstMatch
        profileRefreshButton.tap()
        expectation(for: existsPredicate, evaluatedWith: profileRefreshButton, handler: nil)
        waitForExpectations(timeout: 120, handler: nil)
         */

        // Page view
        goToPage(2)
        let pageRefreshButton = app.buttons["page-refresh-button"]
        pageRefreshButton.tap()
        expectation(for: existsPredicate, evaluatedWith: pageRefreshButton, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        goToLink(1)
        goToLink(3)
        takeScreenshot(named: "01-GadgetsView")
        app.buttons["showcase-view-button"].tap()
        takeScreenshot(named: "02-ShowcaseView")
        app.buttons["blend-view-button"].tap()
        takeScreenshot(named: "03-BlendView")

        // Page settings
        app.buttons["page-settings-button"].tap()
        takeScreenshot(named: "04-PageSettings")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Feed view
        app.buttons["item-feed-button"].tap()
        takeScreenshot(named: "05-FeedView")

        // Feed settings
        app.buttons["feed-settings-button"].tap()
        takeScreenshot(named: "06-FeedSettings")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Search
        let searchField = app.searchFields["Search"]
        searchField.tap()
        searchField.typeText("Apple")
        searchField.typeText("\n")
        let searchGroupHeader = app.scrollViews.otherElements.staticTexts["Apple Newsroom"]
        expectation(for: existsPredicate, evaluatedWith: searchGroupHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        takeScreenshot(named: "07-Search")

        // History
        app.buttons["history-button"].tap()
        let historyHeader = app.navigationBars["History"]
        expectation(for: existsPredicate, evaluatedWith: historyHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        takeScreenshot(named: "08-History")

        // Settings
        app.buttons["settings-button"].tap()
        let settingsHeader = app.navigationBars["Settings"]
        expectation(for: existsPredicate, evaluatedWith: settingsHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        takeScreenshot(named: "09-Settings")
    }

    private func goToPage(_ elementIndex: Int) {
        app.tables.buttons
            .matching(identifier: "page-button")
            .element(boundBy: elementIndex)
            .tap()
    }

    private func goToLink(_ elementIndex: Int) {
        app.buttons
            .matching(identifier: "gadget-item-button")
            .element(boundBy: elementIndex)
            .tap()

        sleep(1)
        app.activate()
    }
}
