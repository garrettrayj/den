//
//  ProfileUITests.swift
//  UI Tests
//
//  Created by Garrett Johnson on 11/1/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class ProfileUITests: UITestCase {
    func testNewProfile() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("New profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()
        
        attachScreenshot(of: app.windows.firstMatch, named: "new-profile")
    }

    #if os(macOS)
    func testProfileSettings() throws {
        let app = launchApp(inMemory: false)

        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        app.buttons["Profiles"].tap()
        app.outlines.staticTexts["Den"].tap()

        attachScreenshot(of: app.windows.firstMatch, named: "profile-settings")
    }
    #else
    func testProfileSettings() throws {
        let app = launchApp(inMemory: false)

        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].tap()
        if !app.buttons["Settings"].waitForExistence(timeout: 2) {
            XCTFail("Settings button did not appear in time")
        }
        app.buttons["Settings"].tap()

        app.buttons["ProfileSettings"].firstMatch.tap()
        
        attachScreenshot(of: app.windows.firstMatch, named: "profile-settings")
    }
    #endif
}
