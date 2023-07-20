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

final class AppSidebarUITests: UITestCase {
    func testAppSidebarGetStarted() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        attachScreenshot(of: app.windows.firstMatch, named: "AppSidebarGetStarted")
    }
    
    func testAppSidebarAppMenu() throws {
        let app = launchApp(inMemory: true)

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

