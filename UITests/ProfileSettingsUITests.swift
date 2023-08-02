//
//  ProfileSettingsUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 8/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class ProfileSettingsUITests: UITestCase {
    func testProfileSettings() throws {
        let app = launchApp(inMemory: false)

        app.buttons["SelectProfile"].firstMatch.tap()
        
        #if os(macOS)
        app.popUpButtons["SidebarMenu"].tap()
        app.menuItems["ShowProfileSettings"].tap()
        #else
        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].forceTap()
        app.buttons["ShowProfileSettings"].tap()
        #endif

        if !app.buttons["Cancel"].waitForExistence(timeout: 4) {
            XCTFail("Settings sheet did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "09-ProfileSettings")
    }
}
