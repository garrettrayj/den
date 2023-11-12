//
//  BlocklistUITests.swift
//  UI Tests
//
//  Created by Garrett Johnson on 11/1/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class BlocklistUITests: UITestCase {
    #if os(macOS)
    func testNewBlocklist() throws {
        let app = launchApp(inMemory: true)

        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        if !app.staticTexts["General"].waitForExistence(timeout: 2) {
            XCTFail("General settings tab did not appear in time")
        }
        
        app.buttons["Blocklists"].tap()
        app.buttons["NewBlocklist"].tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-new")
    }
    #else
    func testNewBlocklist() throws {
        let app = launchApp(inMemory: false)

        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].forceTap()
        app.buttons["Settings"].tap()

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

        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].forceTap()
        app.buttons["Settings"].tap()

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
    #endif
}
