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

        if !app.buttons["InboxNavLink"].waitForExistence(timeout: 10) {
            XCTFail("Inbox button did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "AppLaunchOneProfile")
    }

    func testPosterScreenshot() throws {
        let app = launchApp(inMemory: false)

        if !app.buttons["InboxNavLink"].waitForExistence(timeout: 10) {
            XCTFail("Inbox button did not appear in time")
        }

        #if os(macOS)
        app.textFields["Science"].tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.staticTexts["Science"].tap()
        }
        #endif

        // Wait for images to load
        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "01-AppPoster")
    }
}
