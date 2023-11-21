//
//  TrendingUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class TrendingUITests: UITestCase {
    func testTrending() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

        app.buttons["TrendingNavLink"].tap()

        hideSidebar(app)
        
        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "trending")
    }
    
    func testTrendingEmpty() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()
        app.buttons["CreateProfile"].firstMatch.tap()

        #if os(macOS)
        if !app.outlines.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }
        app.outlines.buttons["NewPage"].tap()
        #else
        if !app.collectionViews.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }
        app.collectionViews.buttons["NewPage"].tap()
        #endif

        app.buttons["CreatePage"].tap()

        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass != .compact {
                app.navigationBars.firstMatch.buttons.firstMatch.tap()
            }
        }
        #endif

        app.buttons["TrendingNavLink"].tap()

        hideSidebar(app)

        attachScreenshot(of: app.windows.firstMatch, named: "trending-empty")
    }
}
