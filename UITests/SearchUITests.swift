//
//  SearchUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class SearchUITests: UITestCase {
    func testSearch() throws {
        let app = launchApp(inMemory: false)

        #if os(iOS)
        app.swipeDown()
        #endif

        let searchField = app.searchFields["Search"].firstMatch
        searchField.tap()
        searchField.typeText("NASA")
        searchField.typeText("\n")

        hideSidebar(app)

        if !app.staticTexts["Search"].waitForExistence(timeout: 2) {
            XCTFail("Search title did not appear in time")
        }

        // For unknown reasons, app.windows.firstMatch does not work on iPhone in the specific
        // situation of taking a screenshot of search results.
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            attachScreenshot(of: app, named: "search")
        } else {
            attachScreenshot(of: app.windows.firstMatch, named: "search")
        }
        #else
        attachScreenshot(of: app.windows.firstMatch, named: "search")
        #endif
    }

    func testSearchNoResults() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("New Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()
        app.buttons["CreateProfile"].firstMatch.tap()

        #if os(iOS)
        app.swipeDown()
        #endif

        let searchField = app.searchFields["Search"].firstMatch
        searchField.tap()
        searchField.typeText("Example")
        searchField.typeText("\n")

        hideSidebar(app)

        if !app.staticTexts["No Results for “Example”"].waitForExistence(timeout: 2) {
            XCTFail("Search status did not appear in time")
        }

        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            attachScreenshot(of: app, named: "SearchNoResults")
        } else {
            attachScreenshot(of: app.windows.firstMatch, named: "search-no-results")
        }
        #else
        attachScreenshot(of: app.windows.firstMatch, named: "search-no-results")
        #endif
    }
}
