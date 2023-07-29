//
//  DiagnosticsUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class DiagnosticsUITests: UITestCase {
    func testDiagnostics() throws {
        let app = launchApp(inMemory: false)
        
        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.popUpbuttons["SidebarMenu"].tap()
        app.menuItems["Diagnostics"].tap()
        #else
        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 4) {
            XCTFail()
        }
        app.buttons["SidebarMenu"].forceTap()
        app.buttons["Diagnostics"].tap()
        #endif

        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular {
                app.tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif

        if !app.staticTexts["Diagnostics"].waitForExistence(timeout: 2) {
            XCTFail("Diagnostics header did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "Diagnostics")
    }

    func testDiagnosticsEmpty() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].tap()

        #if os(macOS)
        app.popUpbuttons["SidebarMenu"].tap()
        app.menuItems["Diagnostics"].tap()
        #else
        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 4) {
            XCTFail()
        }
        app.buttons["SidebarMenu"].forceTap()
        app.buttons["Diagnostics"].tap()
        #endif

        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular {
                app.tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif

        if !app.staticTexts["Diagnostics"].waitForExistence(timeout: 2) {
            XCTFail("Diagnostics header did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "DiagnosticsEmpty")
    }
}
