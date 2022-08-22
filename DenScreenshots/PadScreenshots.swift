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

    func testScreenshots() {
        let getStartedLabel = app.staticTexts["Get Started"]
        expectation(for: existsPredicate, evaluatedWith: getStartedLabel, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        app.buttons["load-demo-button"].tap()

        // Refresh all pages
        let profileRefreshButton = app.buttons.matching(identifier: "profile-refresh-button").firstMatch
        profileRefreshButton.tap()
        expectation(for: enabledPredicate, evaluatedWith: profileRefreshButton, handler: nil)
        waitForExpectations(timeout: 120, handler: nil)

        // Page views
        goToPage(2)

        goToLink(1)
        goToLink(3)

        takeScreenshot(named: "01-GadgetsView")
        app.navigationBars.buttons["page-menu"].forceTap()
        app.buttons["showcase-view-button"].tap()

        // Show page menu in next screenshot
        app.navigationBars.buttons["page-menu"].forceTap()
        takeScreenshot(named: "02-ShowcaseView")

        app.buttons["blend-view-button"].tap()
        takeScreenshot(named: "03-BlendView")

        // Page settings
        app.navigationBars.buttons["page-menu"].forceTap()
        app.buttons["page-settings-button"].tap()
        takeScreenshot(named: "04-PageSettings")
        goBack()

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

        // Settings
        app.buttons["settings-button"].forceTap()
        let settingsHeader = app.navigationBars["Settings"]
        expectation(for: existsPredicate, evaluatedWith: settingsHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        takeScreenshot(named: "08-Settings")
    }

    private func goBack() {
        app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 0).tap()
    }

    private func goToPage(_ elementIndex: Int) {
        app.tables.buttons
            .matching(identifier: "page-button")
            .element(boundBy: elementIndex)
            .tap()
    }

    private func goToLink(_ elementIndex: Int) {
        let itemButton = app.buttons
            .matching(identifier: "gadget-item-button")
            .element(boundBy: elementIndex)
            .firstMatch

        expectation(for: existsPredicate, evaluatedWith: itemButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        itemButton.forceTap()

        let doneButton = app.buttons["Done"]
        expectation(for: existsPredicate, evaluatedWith: doneButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        doneButton.tap()
    }
}
