//
//  AppLaunchUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class AppLaunchUITests: UITestCase {
    func testAppLaunchNoProfiles() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "AppLaunchNoProfiles")
    }

    func testAppLaunchOneProfile() throws {
        let app = launchApp(inMemory: false)
        
        app.buttons["SelectProfile"].firstMatch.tap()

        if !app.staticTexts["InboxNavLink"].waitForExistence(timeout: 10) {
            XCTFail("Inbox button did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "AppLaunchOneProfile")
    }
}
