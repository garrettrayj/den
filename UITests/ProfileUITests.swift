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
    
    func testProfileSettings() throws {
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

        app.buttons["ProfileSettings"].firstMatch.tap()
        
        attachScreenshot(of: app.windows.firstMatch, named: "profile-settings")
    }
}
