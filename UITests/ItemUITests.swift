//
//  ItemUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class ItemUITests: UITestCase {
    func testItemView() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        #else
        app.buttons["Science"].tap()
        #endif
        
        hideSidebar(app)

        app.buttons["ItemAction"].firstMatch.tap()

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "item-browser-view")
    }
    
    func testItemReader() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        #else
        app.buttons["Science"].tap()
        #endif
        
        hideSidebar(app)

        app.buttons["ItemAction"].firstMatch.tap()
        sleep(4)
        
        #if os(macOS)
        app.popUpButtons["FormatMenu"].buttons.firstMatch.tap()
        #else
        app.buttons["FormatMenu"].tap()
        #endif
        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "item-reader-view")
    }
}
