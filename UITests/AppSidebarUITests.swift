//
//  AppSidebarUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/16/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class AppSidebarUITests: UITestCase {
    func testAppSidebarGetStarted() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()

        app.buttons["CreateProfile"].firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "GetStarted")
    }

    func testAppSidebarAppMenu() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.popUpButtons["SidebarMenu"].tap()
        #else
        app.buttons["SidebarMenu"].forceTap()
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "AppMenu")
    }
}
