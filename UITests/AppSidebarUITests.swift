//
//  AppSidebarUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class AppSidebarUITests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppSidebarGetStarted() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        attachScreenshot(of: app.windows.firstMatch, named: "AppSidebarGetStarted")
    }
    
    func testAppSidebarAppMenu() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        #if os(macOS)
        app.popUpButtons["AppMenu"].tap()
        #else
        app.buttons["AppMenu"].forceTap()
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "AppSidebarAppMenu")
    }
}

