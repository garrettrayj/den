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
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        app.buttons["Science"].tap()
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
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

        app.buttons["ItemAction"].firstMatch.tap()

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "ItemView")
    }
    
    func testItemReader() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        app.buttons["Science"].tap()
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
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

        app.buttons["ItemAction"].firstMatch.tap()
        sleep(4)
        
        #if os(macOS)
        app.popUpButtons["FormatMenu"].buttons.firstMatch.tap()
        #else
        app.buttons["FormatMenu"].tap()
        #endif
        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "ItemReader")
    }
}
