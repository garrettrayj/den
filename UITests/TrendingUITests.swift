//
//  TrendingUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class TrendingUITests: UITestCase {
    @MainActor
    func testTrending() throws {
        let app = launchApp(inMemory: false)

        app.staticTexts["TrendingNavLink"].tap()

        hideSidebar(app)
        
        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "trending")
    }
    
    @MainActor
    func testTrendingEmpty() throws {
        let app = launchApp(inMemory: true)

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

        app.staticTexts["TrendingNavLink"].tap()

        hideSidebar(app)

        attachScreenshot(of: app.windows.firstMatch, named: "trending-empty")
    }
}
