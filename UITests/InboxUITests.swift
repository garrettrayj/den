//
//  InboxUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class InboxUITests: UITestCase {
    func testInbox() throws {
        let app = launchApp(inMemory: false)

        app.buttons["InboxNavLink"].tap()

        #if os(macOS)
        app.buttons["Hide Sidebar"].firstMatch.tap()
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

        if !app.staticTexts["Inbox"].waitForExistence(timeout: 2) {
            XCTFail("Inbox title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "Inbox")
    }

    func testInboxEmpty() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()
        app.buttons["CreateProfile"].firstMatch.tap()

        if !app.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }

        app.buttons["NewPage"].tap()
        app.buttons["CreatePage"].tap()

        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.navigationBars.firstMatch.buttons.firstMatch.tap()
            }
        }
        #endif

        if !app.buttons["InboxNavLink"].waitForExistence(timeout: 2) {
            XCTFail("Inbox button did not appear in time")
        }
        app.buttons["InboxNavLink"].tap()

        #if os(macOS)
        app.buttons["Hide Sidebar"].firstMatch.tap()
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

        if !app.staticTexts["Inbox"].waitForExistence(timeout: 2) {
            XCTFail("Inbox title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "InboxEmpty")
    }
}
