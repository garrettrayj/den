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
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchNoProfiles() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        
        attachScreenshot(of: app.windows.firstMatch, named: "AppLaunchNoProfiles")
    }
    
    func testAppLaunchOneProfile() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["Inbox"].waitForExistence(timeout: 2) {
            XCTFail("Inbox button did not appear in time")
        }
        
        attachScreenshot(of: app.windows.firstMatch, named: "AppLaunchOneProfile")
    }
}
