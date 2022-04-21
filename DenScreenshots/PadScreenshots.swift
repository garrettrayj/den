//
//  PadScreenshots.swift
//  PadScreenshots
//
//  Created by Garrett Johnson on 7/30/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

// swiftlint:disable function_body_length

import XCTest

class PadScreenshots: ScreenshotTestCase {
    override var targetIdiom: UIUserInterfaceIdiom { .pad }

    func testScreenshots() {
        let getStartedLabel = app.staticTexts["Get Started"]
        expectation(for: existsPredicate, evaluatedWith: getStartedLabel, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        app.buttons["load-demo-button"].tap()

        // Refresh all pages
        app.buttons["profile-refresh-button"].tap()

        // Page views
        goToPage(2)

        goToLink(1)
        goToLink(3)

        takeScreenshot(named: "01-GadgetsView")
        app.navigationBars.buttons["page-menu"].forceTap()
        app.buttons["showcase-view-button"].tap()
        takeScreenshot(named: "02-ShowcaseView")
        app.navigationBars.buttons["page-menu"].forceTap()
        app.buttons["blend-view-button"].tap()
        takeScreenshot(named: "03-BlendView")

        // Page settings
        app.navigationBars.buttons["page-menu"].forceTap()
        app.buttons["page-settings-button"].tap()
        takeScreenshot(named: "04-PageSettings")
        app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 0).tap()

        // Feed view
        app.buttons.matching(identifier: "item-feed-button").firstMatch.forceTap()
        takeScreenshot(named: "05-FeedView")

        // Feed settings
        app.buttons["feed-settings-button"].forceTap()
        takeScreenshot(named: "06-FeedSettings")

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
        app.buttons["history-button"].forceTap()
        let historyHeader = app.navigationBars["History"]
        expectation(for: existsPredicate, evaluatedWith: historyHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        takeScreenshot(named: "08-History")

        // Settings
        app.buttons["settings-button"].forceTap()
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
            .firstMatch
            .forceTap()

        let doneButton = app.buttons["Done"]
        expectation(for: existsPredicate, evaluatedWith: doneButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        doneButton.tap()
    }
}
