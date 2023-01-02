//
//  PadScreenshots.swift
//  PadScreenshots
//
//  Created by Garrett Johnson on 7/30/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

class PadScreenshots: ScreenshotTestCase {
    override var targetIdiom: UIUserInterfaceIdiom { .pad }

    func testScreenshots() {
        if !app.staticTexts["GET STARTED"].waitForExistence(timeout: 5) {
            XCTFail("Get Started message does not exist")
        }
        app.buttons["load-demo-button"].forceTap()

        // Refresh all pages
        let profileRefreshButton = app.buttons.matching(identifier: "profile-refresh-button").firstMatch
        profileRefreshButton.tap()
        expectation(for: enabledPredicate, evaluatedWith: profileRefreshButton, handler: nil)
        waitForExpectations(timeout: 120, handler: nil)

        // Page views
        goToPage(5)

        goToLink(1)
        goToLink(3)

        takeScreenshot(named: "01-GadgetsView")

        app.buttons["page-menu"].tap()
        app.buttons["showcase-view-button"].tap()

        // Show page menu in next screenshot
        app.buttons["page-menu"].tap()
        takeScreenshot(named: "02-ShowcaseView")

        app.buttons["blend-view-button"].tap()
        sleep(2)
        takeScreenshot(named: "03-BlendView")

        // Page settings
        app.buttons["page-menu"].tap()
        app.buttons["page-settings-button"].tap()
        sleep(2)
        takeScreenshot(named: "04-PageSettings")
        goBack()

        // Feed view
        app.buttons["item-feed-button"].firstMatch.tap()
        takeScreenshot(named: "05-FeedView")

        // Feed settings
        app.buttons["feed-settings-button"].tap()
        sleep(2)
        takeScreenshot(named: "06-FeedSettings")

        // Settings
        app.buttons["settings-button"].tap()
        if !app.buttons["Den"].waitForExistence(timeout: 5) { XCTFail("Profile button does not exist") }
        takeScreenshot(named: "07-Settings")

        // Search
        let searchField = app.searchFields["Search"]
        searchField.tap()
        searchField.typeText("NASA")
        searchField.typeText("\n")
        sleep(1)
        takeScreenshot(named: "08-Search")
    }

    private func goBack() {
        app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 0).tap()
    }

    private func goToPage(_ elementIndex: Int) {
        app.staticTexts
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
        itemButton.tap()

        let backButton = app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 0)
        expectation(for: existsPredicate, evaluatedWith: backButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        backButton.tap()
    }
}
