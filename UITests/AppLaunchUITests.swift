//
//  AppLaunchUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import XCTest

final class AppLaunchUITests: UITestCase {
    func testAppLaunchNoProfiles() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("New profile button did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "app-launch-no-profiles")
    }

    func testAppLaunchMultipleProfiles() throws {
        let app = launchApp(inMemory: false)

        if !app.buttons["SelectProfile"].waitForExistence(timeout: 10) {
            XCTFail("Select profile button did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "app-launch-multiple-profiles")
    }

    func testPosterScreenshot() throws {
        let app = launchApp(inMemory: false)
        
        if !app.buttons["SelectProfile"].firstMatch.waitForExistence(timeout: 10) {
            XCTFail("Select profile button did not appear in time")
        }
        app.buttons["SelectProfile"].firstMatch.tap()

        if !app.staticTexts["InboxNavLink"].waitForExistence(timeout: 10) {
            XCTFail("Inbox button did not appear in time")
        }

        #if os(macOS)
        app.textFields.matching(identifier: "SidebarPage").element(boundBy: 4).tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.staticTexts["Science"].tap()
        }
        #endif

        // Wait for images to load
        sleep(8)

        attachScreenshot(of: app.windows.firstMatch, named: "app-poster")
    }
}
