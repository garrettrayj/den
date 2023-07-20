//
//  SearchUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
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
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular {
                app.tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isPortrait {
                app.tap()
            }
        }
        #endif

        if !app
            .staticTexts
            .containing(NSPredicate(format: "label CONTAINS[c] %@", "results for “NASA”"))
            .firstMatch
            .waitForExistence(timeout: 2)
        {
            XCTFail()
        }
        
        // For unknown reasons, app.windows.firstMatch does not work on iOS in the specific
        // situation of taking a screenshot of search results.
        #if os(iOS)
        attachScreenshot(of: app, named: "Search")
        #else
        attachScreenshot(of: app.windows.firstMatch, named: "Search")
        #endif
    }
    
    func testSearchNoResults() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        #if os(iOS)
        app.swipeDown()
        #endif
        
        let searchField = app.searchFields["Search"].firstMatch
        searchField.tap()
        searchField.typeText("Example")
        searchField.typeText("\n")
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular {
                app.tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif
        
        if !app.staticTexts["No results found for “Example”"].waitForExistence(timeout: 2) {
            XCTFail()
        }

        #if os(iOS)
        attachScreenshot(of: app, named: "SearchNoResults")
        #else
        attachScreenshot(of: app.windows.firstMatch, named: "SearchNoResults")
        #endif
    }
}
