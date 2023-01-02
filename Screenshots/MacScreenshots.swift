//
//  MacScreenshots.swift
//  MacScreenshots
//
//  Created by Garrett Johnson on 7/30/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

class MacScreenshots: ScreenshotTestCase {
    override var targetIdiom: UIUserInterfaceIdiom { .mac }

    func testScreenshots() {
        // Page list
        app.buttons["load-demo-button"].tap()

        // Refresh all pages
        let profileRefreshButton = app.buttons.matching(identifier: "profile-refresh-button").firstMatch
        profileRefreshButton.forceTap()
        expectation(for: enabledPredicate, evaluatedWith: profileRefreshButton, handler: nil)
        waitForExpectations(timeout: 120, handler: nil)

        goToPage(5)

        goToLink(1)
        goToLink(3)

        sleep(2)
        takeScreenshot(named: "01-GadgetsView")

        app.buttons["showcase-view-button"].tap()
        sleep(2)
        takeScreenshot(named: "02-ShowcaseView")

        app.buttons["blend-view-button"].tap()
        sleep(2)
        takeScreenshot(named: "03-BlendView")

        // Page settings
        app.buttons["page-settings-button"].tap()
        sleep(2)
        takeScreenshot(named: "04-PageSettings")
        goBack()

        // Feed view
        app.buttons["gadgets-view-button"].tap()
        app.buttons.matching(identifier: "gadget-feed-button").firstMatch.tap()
        sleep(2)
        takeScreenshot(named: "05-FeedView")

        // Feed settings
        app.buttons["feed-settings-button"].tap()
        sleep(2)
        takeScreenshot(named: "06-FeedSettings")
        goBack()

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

        _ = itemButton.waitForExistence(timeout: 10)
        itemButton.tap()

        let backButton = app.buttons["Back"].firstMatch
        _ = backButton.waitForExistence(timeout: 10)
        backButton.tap()
    }

    private func goBack() {
        app.buttons["Back"].firstMatch.tap()
    }
}
