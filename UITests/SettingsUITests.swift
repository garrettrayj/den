//
//  SettingsUITests.swift
//  UI Tests
//
//  Created by Garrett Johnson on 10/24/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import XCTest

final class SettingsUITests: UITestCase {
    #if os(macOS)
    @MainActor
    func testAppSettings() throws {
        let app = launchApp(inMemory: false)

        app.menuBarItems["Den"].menuItems["Settings…"].tap()

        attachScreenshot(of: app.windows.element(boundBy: 1), named: "settings")
    }
    #else
    @MainActor
    func testSettings() throws {
        let app = launchApp(inMemory: false)

        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].tap()
        if !app.buttons["Settings"].waitForExistence(timeout: 2) {
            XCTFail("Settings button did not appear in time")
        }
        app.buttons["Settings"].tap()

        if !app.staticTexts["Settings"].waitForExistence(timeout: 2) {
            XCTFail("Settings header did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "settings")
    }
    #endif
}
