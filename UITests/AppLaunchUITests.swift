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

final class AppLaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchNoProfile() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "AppLaunchNoProfile"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testAppLaunchOneProfile() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["Inbox"].waitForExistence(timeout: 2) {
            XCTFail("Inbox button did not appear in time")
        }

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "AppLaunchOneProfile"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
