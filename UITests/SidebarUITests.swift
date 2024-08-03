//
//  SidebarUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class SidebarUITests: UITestCase {
    @MainActor
    func testSidebarGetStarted() throws {
        let app = launchApp(inMemory: true)

        attachScreenshot(of: app.windows.firstMatch, named: "sidebar-get-started")
    }

    @MainActor
    func testSidebarAppMenu() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.popUpButtons["SidebarMenu"].tap()
        #else
        app.buttons["SidebarMenu"].tap()
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "sidebar-app-menu")
    }
}
