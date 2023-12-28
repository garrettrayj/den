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
        app.buttons["SelectProfile"].firstMatch.tap()

        app.buttons["InboxNavLink"].tap()

        hideSidebar(app)
        
        #if os(iOS)
        app.swipeDown()
        #endif

        let searchField = app.searchFields["Search"].firstMatch
        searchField.tap()
        searchField.typeText("NASA")
        searchField.typeText("\n")

        #if os(iOS)
        if !app.staticTexts["Searching for “NASA”"].waitForExistence(timeout: 2) {
            XCTFail("Search title did not appear in time")
        }
        #endif
        
        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "search")
    }

    func testSearchNoResults() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

        app.buttons["InboxNavLink"].tap()

        hideSidebar(app)
        
        #if os(iOS)
        app.swipeDown()
        #endif

        let searchField = app.searchFields["Search"].firstMatch
        searchField.tap()
        searchField.typeText("Example 123")
        searchField.typeText("\n")

        if !app.staticTexts["No Results"].waitForExistence(timeout: 2) {
            XCTFail("Search status did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "search")
    }
}
