//
//  ProfileOptionsUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 8/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class ProfileOptionsUITests: UITestCase {
    func testProfileSettings() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.popUpButtons["SidebarMenu"].tap()
        app.menuItems["ShowProfileSettings"].tap()
        #else
        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].forceTap()
        app.buttons["ShowProfileOptions"].tap()
        #endif

        if !app.buttons["Cancel"].waitForExistence(timeout: 4) {
            XCTFail("Profile options sheet did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "09-ProfileOptions")
    }
}
