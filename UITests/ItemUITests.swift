//
//  ItemUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class ItemUITests: UITestCase {
    func testItemView() throws {
        let app = launchApp(inMemory: false)
        
        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.outlines["Sidebar"].cells.element(boundBy: 10).tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular && app.windows.firstMatch.verticalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 6).tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 8).tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.tap()
            }
        }
        #endif

        app.buttons["ItemAction"].firstMatch.tap()

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "ItemView")
    }
}
