//
//  BlocklistUITests.swift
//  UI Tests
//
//  Created by Garrett Johnson on 11/1/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class BlocklistUITests: UITestCase {
    func testNewBlocklist() throws {
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
        
        app.buttons["NewBlocklist"].tap()
        
        app.buttons["BlocklistPresets"].staticTexts.firstMatch.tap()
        
        app.buttons["EasyPrivacy"].tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-new")
    }

    func testBlocklistSettings() throws {
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
        
        app.buttons["NewBlocklist"].tap()
        
        app.buttons["BlocklistPresets"].staticTexts.firstMatch.tap()
        
        app.buttons["EasyPrivacy"].tap()
        
        app.buttons["AddBlocklist"].tap()
        
        sleep(10)
        
        if !app.buttons["BlocklistNavLink"].waitForExistence(timeout: 10) {
            XCTFail("Nav link did not appear in time")
        }
        
        app.buttons["BlocklistNavLink"].tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-settings")
    }

    func testBlocklistRefresh() throws {
        XCTFail("Missing test")
    }

    func testDeleteBlocklist() throws {
        XCTFail("Missing test")
    }
}
