//
//  SettingsUITests.swift
//  UI Tests
//
//  Created by Garrett Johnson on 10/24/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class SettingsUITests: UITestCase {
    func testSettings() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.popUpButtons["SidebarMenu"].tap()
        app.menuItems["Settings"].tap()
        #else
        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].forceTap()
        app.buttons["Settings"].tap()
        #endif

        if !app.staticTexts["Settings"].waitForExistence(timeout: 2) {
            XCTFail("Settings header did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "Settings")
    }
    
    func testNewBlocklist() throws {
        XCTFail("Missing test")
    }
    
    func testBlocklistSettings() throws {
        XCTFail("Missing test")
    }
    
    func testBlocklistRefresh() throws {
        XCTFail("Missing test")
    }
    
    func testDeleteBlocklist() throws {
        XCTFail("Missing test")
    }
}
