//
//  BlocklistUITests.swift
//  UI Tests
//
//  Created by Garrett Johnson on 11/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import XCTest

final class BlocklistUITests: UITestCase {
    #if os(macOS)
    func testNewBlocklist() throws {
        let app = launchApp(inMemory: true)

        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        app.buttons["Blocklists"].tap()
        app.buttons["NewBlocklist"].tap()

        attachScreenshot(of: app.windows.element(boundBy: 1), named: "blocklist-new")
    }
    
    func testBlocklistSettings() throws {
        let app = launchApp(inMemory: false)

        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        app.buttons["Blocklists"].tap()
        
        app.buttons["NewBlocklist"].tap()
        
        app.buttons["BlocklistPresets"].tap()
        
        app.buttons["BlocklistPresetOption"].firstMatch.tap()
        
        app.buttons["AddBlocklist"].tap()
        
        sleep(15)
        
        app.outlines.staticTexts["EasyList"].tap()

        attachScreenshot(of: app.windows.element(boundBy: 1), named: "blocklist-settings")
    }
    #else
    func testNewBlocklist() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

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
        
        app.buttons["NewBlocklist"].tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-new")
    }

    func testBlocklistSettings() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].tap()
        
        if !app.buttons["Settings"].waitForExistence(timeout: 4) {
            XCTFail("Settings button did not appear in time")
        }
        app.buttons["Settings"].tap()

        if !app.staticTexts["Settings"].waitForExistence(timeout: 2) {
            XCTFail("Settings header did not appear in time")
        }
        
        app.buttons["NewBlocklist"].tap()
        
        app.buttons["BlocklistPresets"].tap()
        
        app.buttons["BlocklistPresetOption"].firstMatch.tap()
        
        app.buttons["AddBlocklist"].tap()
        
        sleep(15)
        
        if !app.buttons["BlocklistNavLink"].waitForExistence(timeout: 10) {
            XCTFail("Nav link did not appear in time")
        }
        
        app.buttons["BlocklistNavLink"].tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-settings")
    }
    #endif
}
