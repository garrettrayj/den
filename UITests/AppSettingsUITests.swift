//
//  AppSettingsUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class AppSettingsUITests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testShowAppSettings() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["create-profile-button"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["create-profile-button"].tap()
        
        #if os(macOS)
        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        if !app.staticTexts["General"].waitForExistence(timeout: 2) {
            XCTFail("Settings window did not appear in time")
        }
        #else
        app.buttons["app-menu"].tap()
        app.buttons["settings-button"].tap()
        if !app.buttons["close-button"].waitForExistence(timeout: 2) {
            XCTFail("Settings sheet did not appear in time")
        }
        #endif
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "AppSettings"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.terminate()
    }
}
