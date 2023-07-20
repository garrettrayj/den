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
        
        if !app.staticTexts["Inbox"].waitForExistence(timeout: 2) {
            XCTFail()
        }

        attachScreenshot(of: app.windows.firstMatch, named: "Inbox")
    }

    func testInboxEmpty() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.buttons["NewPage"].tap()
        
        app.buttons["InboxNavLink"].tap()
        
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
        
        if !app.staticTexts["Inbox"].waitForExistence(timeout: 2) {
            XCTFail()
        }

        attachScreenshot(of: app.windows.firstMatch, named: "InboxEmpty")
    }
}
