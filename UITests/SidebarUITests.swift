//
//  SidebarUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/16/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class SidebarUITests: UITestCase {
    func testGetStarted() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()

        app.buttons["CreateProfile"].firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "get-started")
    }

    func testAppMenu() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.popUpButtons["SidebarMenu"].tap()
        #else
        app.buttons["SidebarMenu"].tap()
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "app-menu")
    }
    
    func testProfileMenu() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.popUpButtons["ProfileMenu"].tap()
        #else
        app.buttons["ProfileMenu"].tap()
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "profile-menu")
    }
}
