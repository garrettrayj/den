//
//  PhoneScreenshots.swift
//  PhoneScreenshots
//
//  Created by Garrett Johnson on 7/17/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

// swiftlint:disable function_body_length

import XCTest

class PhoneScreenshots: ScreenshotTestCase {
    override var targetIdiom: UIUserInterfaceIdiom { .phone }

    func testScreenshots() {
        let getStartedLabel = app.staticTexts["GET STARTED"]
        expectation(for: existsPredicate, evaluatedWith: getStartedLabel, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        app.buttons["load-demo-button"].tap()

        // Refresh all pages
        let profileRefreshButton = app.buttons.matching(identifier: "profile-refresh-button").firstMatch
        profileRefreshButton.tap()
        expectation(for: enabledPredicate, evaluatedWith: profileRefreshButton, handler: nil)
        waitForExpectations(timeout: 120, handler: nil)

        takeScreenshot(named: "01-PageList")

        // Page views
        goToPage(5)

        goToLink(1)
        goToLink(3)

        takeScreenshot(named: "02-GadgetsView")

        app.navigationBars.buttons["page-menu"].tap()
        app.buttons["showcase-view-button"].tap()
        sleep(2)
        takeScreenshot(named: "03-ShowcaseView")
        
        app.navigationBars.buttons["page-menu"].tap()
        app.buttons["blend-view-button"].tap()
        sleep(2)
        takeScreenshot(named: "04-BlendView")

        // Page settings
        app.navigationBars.buttons["page-menu"].tap()
        app.buttons["page-settings-button"].tap()
        sleep(2)
        takeScreenshot(named: "04-PageSettings")

        goBack()

        // Feed view
        app.buttons.matching(identifier: "item-feed-button").firstMatch.forceTap()
        sleep(2)
        takeScreenshot(named: "05-FeedView")

        // Feed settings
        app.buttons["feed-settings-button"].forceTap()
        sleep(2)
        takeScreenshot(named: "06-FeedSettings")

        goBack()
        goBack()
        goBack()

        // Settings
        app.buttons["settings-button"].forceTap()
        let settingsHeader = app.navigationBars["Settings"]
        expectation(for: existsPredicate, evaluatedWith: settingsHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        takeScreenshot(named: "07-Settings")

        goBack()

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

        expectation(for: existsPredicate, evaluatedWith: itemButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        itemButton.tap()

        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        expectation(for: existsPredicate, evaluatedWith: backButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        backButton.tap()
    }

    private func goBack() {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
}
