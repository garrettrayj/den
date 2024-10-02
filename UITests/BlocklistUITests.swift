//
//  BlocklistUITests.swift
//  UI Tests
//
//  Created by Garrett Johnson on 11/1/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import XCTest

final class BlocklistUITests: UITestCase {
    @MainActor
    func testNewBlocklist() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        #else
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
        #endif
        
        app.buttons["NewBlocklist"].tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-new")
    }

    @MainActor
    func testBlocklistSettings() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        #else
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
        #endif
        
        app.buttons["NewBlocklist"].tap()
        
        app.buttons["BlocklistPresets"].tap()
        
        sleep(3)
        
        app.buttons["BlocklistPresetOption"].firstMatch.tap()
        
        app.buttons["AddBlocklist"].tap()
        
        sleep(15)
        
        if !app.buttons["BlocklistNavLink"].waitForExistence(timeout: 10) {
            XCTFail("Nav link did not appear in time")
        }
        
        app.buttons["BlocklistNavLink"].firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-settings")
    }
}
