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

        #if os(macOS)
        app.textFields.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        #else
        app.staticTexts["Science"].tap()
        #endif
        
        hideSidebar(app)

        app.buttons["ItemAction"].firstMatch.tap()

        sleep(5)

        attachScreenshot(of: app.windows.firstMatch, named: "item-browser-view")
    }
    
    func testItemReader() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        #else
        app.staticTexts["Science"].tap()
        #endif
        
        hideSidebar(app)

        app.buttons["ItemAction"].firstMatch.tap()
        sleep(4)
        
        #if os(macOS)
        app.popUpButtons["FormatMenu"].buttons.firstMatch.tap()
        #else
        app.buttons["FormatMenu"].tap()
        #endif
        sleep(5)

        attachScreenshot(of: app.windows.firstMatch, named: "item-reader-view")
    }
}
