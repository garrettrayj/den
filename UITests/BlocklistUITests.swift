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
        app.buttons["Blocklists"].tap()
        app.buttons["NewBlocklist"].tap()
        app.popUpButtons["BlocklistPresets"].tap()
        app.menuItems["EasyList"].tap()
        app.popUpButtons["BlocklistPresets"].tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-new")
    }
    
    func testBlockSettings() throws {
        let app = launchApp(inMemory: false)

        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        app.buttons["Blocklists"].tap()
        
        app.buttons["NewBlocklist"].tap()
        
        app.popUpButtons["BlocklistPresets"].tap()
        app.menuItems["EasyList"].tap()
        app.buttons["AddBlocklist"].tap()
        
        sleep(15)
        
        app.outlines.staticTexts["EasyList"].tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-settings")
    }
    #else
    func testNewBlocklist() throws {
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
        
        app.buttons["NewBlocklist"].tap()
        
        app.buttons["BlocklistPresets"].staticTexts.firstMatch.tap()
        
        app.buttons["EasyPrivacy"].tap()
        
        app.buttons["BlocklistPresets"].staticTexts.firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "blocklist-new")
    }

    func testBlocklistSettings() throws {
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
        
        app.buttons["NewBlocklist"].tap()
        
        app.buttons["BlocklistPresets"].staticTexts.firstMatch.tap()
        
        app.buttons["EasyList"].tap()
        
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
