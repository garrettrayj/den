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

    func testGetStarted() {
        let getStartedLabel = app.staticTexts["GET STARTED"]
        expectation(for: existsPredicate, evaluatedWith: getStartedLabel, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "1-GetStarted")
    }

    func testPageList() {
        loadDemoFeeds()

        // Wait for pages to appear
        let pageButtonPredicate = NSPredicate(format: "label CONTAINS 'World News'")
        let pageButton = app.tables.buttons.containing(pageButtonPredicate).firstMatch
        expectation(for: existsPredicate, evaluatedWith: pageButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        takeScreenshot(named: "2-PageList")
    }

    func testPage() {
        loadDemoFeeds()

        refreshPage("Science")

        let predicate = NSPredicate(format: "label CONTAINS 'Livescience.com'")
        let feedHeader = app.staticTexts.containing(predicate).firstMatch
        expectation(for: existsPredicate, evaluatedWith: feedHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "3-PageView")
    }

    func testPageSettings() {
        loadDemoFeeds()

        refreshPage("Science")

        let pageSettingsButton = app.navigationBars["Science"].buttons["Wrench"]
        expectation(for: existsPredicate, evaluatedWith: pageSettingsButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        pageSettingsButton.tap()

        let backButton = app.navigationBars["Page Settings"].buttons["Science"]
        expectation(for: existsPredicate, evaluatedWith: backButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "4-PageSettings")
    }

    func testFeedSettings() {
        loadDemoFeeds()

        refreshPage("Science")

        let feedHeaderPredicate = NSPredicate(format: "label CONTAINS 'Livescience.com'")
        let feedHeader = app.staticTexts.containing(feedHeaderPredicate).firstMatch
        expectation(for: existsPredicate, evaluatedWith: feedHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        let feedSettingsButton = app.buttons.matching(identifier: "Feed Settings").firstMatch
        expectation(for: existsPredicate, evaluatedWith: feedSettingsButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        feedSettingsButton.tap()

        let closeButton = app.navigationBars["Feed Settings"].buttons["Close"]
        expectation(for: existsPredicate, evaluatedWith: closeButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "5-FeedSettings")
    }

    func testSearch() {
        loadDemoFeeds()

        refreshPage("Technology")

        app.tabBars["Tab Bar"].buttons["Search"].tap()

        let searchTextField = app.textFields["Search…"]
        searchTextField.tap()
        searchTextField.typeText("Apple")
        searchTextField.typeText("\n")

        let searchGroupHeader = app.scrollViews.otherElements.staticTexts["Apple Newsroom"]
        expectation(for: existsPredicate, evaluatedWith: searchGroupHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "6-Search")
    }

    func testHistory() {
        loadDemoFeeds()

        refreshPage("Gaming")

        gotoLink(1)
        gotoLink(3)
        gotoLink(6)
        gotoLink(8)

        app.activate()

        app.tabBars["Tab Bar"].buttons["History"].tap()

        let historyHeader = app.navigationBars["History"]
        expectation(for: existsPredicate, evaluatedWith: historyHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "7-History")
    }

    func testSettings() {
        app.tabBars["Tab Bar"].buttons["Settings"].tap()

        let settingsHeader = app.navigationBars["Settings"]
        expectation(for: existsPredicate, evaluatedWith: settingsHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "8-Settings")
    }

    private func loadDemoFeeds() {
        let loadDemoButton = app.tables.buttons["Load Demo Feeds"]
        expectation(for: existsPredicate, evaluatedWith: loadDemoButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        loadDemoButton.tap()
    }

    private func refreshPage(_ pageName: String) {
        let pageButtonPredicate = NSPredicate(format: "label CONTAINS '\(pageName)'")
        let pageButton = app.tables.buttons.containing(pageButtonPredicate).firstMatch
        expectation(for: existsPredicate, evaluatedWith: pageButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        pageButton.tap()

        let refreshButton = app.navigationBars[pageName].buttons["refresh"]
        expectation(for: existsPredicate, evaluatedWith: refreshButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        refreshButton.tap()

        let refreshLabel = app.staticTexts["Refresh to Fetch Content"]
        expectation(for: notExistsPredicate, evaluatedWith: refreshLabel, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)

        let emptyLabel = app.staticTexts["Feed Empty"]
        expectation(for: notExistsPredicate, evaluatedWith: emptyLabel, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
    }

    private func gotoPageSettings(pageName: String) {
        let pageMenuButton = app.navigationBars[pageName].buttons["Page Menu"]
        expectation(for: existsPredicate, evaluatedWith: pageMenuButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        pageMenuButton.tap()
    }

    private func gotoLink(_ elementIndex: Int) {
        let elementsQuery = app.scrollViews.otherElements

        elementsQuery
            .buttons
            .matching(identifier: "Item Link")
            .element(boundBy: elementIndex)
            .tap()

        let doneButton = app.buttons["Done"]
        expectation(for: existsPredicate, evaluatedWith: doneButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        doneButton.tap()
    }
}
