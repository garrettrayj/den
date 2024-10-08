//
//  SearchUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import XCTest

final class SearchUITests: UITestCase {
    @MainActor
    func testSearch() throws {
        let app = launchApp(inMemory: false)

        #if os(iOS)
        let firstCell = app.cells.element(boundBy: 0)
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 3))
        start.press(forDuration: 0, thenDragTo: finish)
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

    @MainActor
    func testSearchNoResults() throws {
        let app = launchApp(inMemory: true)

        #if os(iOS)
        let firstCell = app.cells.element(boundBy: 0)
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 3))
        start.press(forDuration: 0, thenDragTo: finish)
        #endif

        let searchField = app.searchFields["Search"].firstMatch
        searchField.tap()
        searchField.typeText("Example")
        searchField.typeText("\n")

        hideSidebar(app)

        if !app.staticTexts["No Results"].waitForExistence(timeout: 2) {
            XCTFail("Search status did not appear in time")
        }

        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            attachScreenshot(of: app, named: "search-no-results")
        } else {
            attachScreenshot(of: app.windows.firstMatch, named: "search-no-results")
        }
        #else
        attachScreenshot(of: app.windows.firstMatch, named: "search-no-results")
        #endif
    }
}
