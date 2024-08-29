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
    @MainActor
    func testItemView() throws {
        let app = launchApp(inMemory: false)

        app.staticTexts.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        
        hideSidebar(app)
        
        #if os(macOS)
        app.radioButtons["GroupedLayout"].tap()
        #else
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["GroupedLayout"].tap()
        #endif

        app.buttons["ItemAction"].firstMatch.tap()

        sleep(5)

        attachScreenshot(of: app.windows.firstMatch, named: "item-browser-view")
    }
    
    @MainActor
    func testItemReader() throws {
        let app = launchApp(inMemory: false)

        app.staticTexts.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        
        hideSidebar(app)
        
        #if os(macOS)
        app.radioButtons["GroupedLayout"].tap()
        #else
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["GroupedLayout"].tap()
        #endif

        app.buttons["ItemAction"].firstMatch.tap()
        sleep(4)
        
        #if os(macOS)
        app.popUpButtons["BrowserViewMenu"].buttons.firstMatch.tap()
        #else
        app.buttons["BrowserViewMenu"].tap()
        #endif
        sleep(5)

        attachScreenshot(of: app.windows.firstMatch, named: "item-reader-view")
    }
}
