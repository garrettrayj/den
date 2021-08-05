//
//  PhoneScreenshots.swift
//  PhoneScreenshots
//
//  Created by Garrett Johnson on 7/17/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

// swiftlint:disable function_body_length

import XCTest

class PhoneScreenshots: ScreenshotTestCase {
    override var targetIdiom: UIUserInterfaceIdiom { .phone }

    func testScreenshots() {
        let getStartedLabel = app.staticTexts["GET STARTED"]
        expectation(for: existsPredicate, evaluatedWith: getStartedLabel, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        takeScreenshot(named: "1-GetStarted")

        loadDemoFeeds()

        // Wait for pages to appear
        let pageButtonPredicate = NSPredicate(format: "label CONTAINS 'World News'")
        let pageButton = app.tables.buttons.containing(pageButtonPredicate).firstMatch
        expectation(for: existsPredicate, evaluatedWith: pageButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        takeScreenshot(named: "2-PageList")

        goToPage("Technology")
        refreshPage("Technology")

        goToLink(8)
        goToLink(6)
        goToLink(3)
        goToLink(1)

        let predicate = NSPredicate(format: "label CONTAINS 'Ars Technica'")
        let feedHeader = app.staticTexts.containing(predicate).firstMatch
        expectation(for: existsPredicate, evaluatedWith: feedHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "3-PageView")

        let pageMenuButton = app.navigationBars["Technology"].buttons["Page Menu"]
        expectation(for: existsPredicate, evaluatedWith: pageMenuButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        pageMenuButton.tap()

        let pageSettingsButton = app.collectionViews.buttons["Page Settings"]
        expectation(for: existsPredicate, evaluatedWith: pageSettingsButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        pageSettingsButton.tap()

        let backButton = app.navigationBars["Page Settings"].buttons["Technology"]
        expectation(for: existsPredicate, evaluatedWith: backButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "4-PageSettings")
        backButton.tap()

        app.scrollViews
            .children(matching: .other)
            .element(boundBy: 0)
            .children(matching: .other)
            .element
            .children(matching: .button)
            .matching(identifier: "Feed Settings")
            .element(boundBy: 0)
            .tap()

        let closeButton = app.navigationBars["Feed Settings"].buttons["Close"]
        expectation(for: existsPredicate, evaluatedWith: closeButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "5-FeedSettings")
        closeButton.tap()

        app.tabBars["Tab Bar"].buttons["Search"].tap()

        let searchTextField = app.textFields["Search…"]
        searchTextField.tap()
        searchTextField.typeText("Apple")
        searchTextField.typeText("\n")

        let searchGroupHeader = app.scrollViews.otherElements.staticTexts["Apple Newsroom"]
        expectation(for: existsPredicate, evaluatedWith: searchGroupHeader, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        takeScreenshot(named: "6-Search")

        app.tabBars["Tab Bar"].buttons["History"].tap()

        let historyHeader = app.navigationBars["History"]
        expectation(for: existsPredicate, evaluatedWith: historyHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "7-History")

        app.tabBars["Tab Bar"].buttons["Settings"].tap()

        let settingsHeader = app.navigationBars["Settings"]
        expectation(for: existsPredicate, evaluatedWith: settingsHeader, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        takeScreenshot(named: "8-Settings")
    }

    private func loadDemoFeeds() {
        // Load demo pages
        let loadDemoButton = app.tables.buttons["Load Demo Feeds"]
        expectation(for: existsPredicate, evaluatedWith: loadDemoButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        loadDemoButton.tap()
    }

    private func goToPage(_ pageName: String) {
        let pageButtonPredicate = NSPredicate(format: "label CONTAINS '\(pageName)'")
        let pageButton = app.tables.buttons.containing(pageButtonPredicate).firstMatch
        expectation(for: existsPredicate, evaluatedWith: pageButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        pageButton.tap()
    }

    private func refreshPage(_ pageName: String) {
        let pageMenuButton = app.navigationBars[pageName].buttons["Page Menu"]
        expectation(for: existsPredicate, evaluatedWith: pageMenuButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        pageMenuButton.tap()

        let refreshButton = app.collectionViews.buttons["Refresh"]
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

    private func goToLink(_ elementIndex: Int) {
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
