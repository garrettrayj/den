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
    @MainActor
    func testInbox() throws {
        let app = launchApp(inMemory: false)

        app.staticTexts["InboxNavLink"].tap()

        hideSidebar(app)

        if !app.staticTexts["Inbox"].waitForExistence(timeout: 2) {
            XCTFail("Inbox title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "inbox")
    }

    @MainActor
    func testInboxEmpty() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }

        #if os(macOS)
        app.outlines.buttons["NewPage"].tap()
        #else
        app.collectionViews.buttons["NewPage"].tap()
        #endif
        
        app.buttons["CreatePage"].tap()

        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.navigationBars.firstMatch.buttons.firstMatch.tap()
            }
        }
        #endif

        if !app.staticTexts["InboxNavLink"].waitForExistence(timeout: 2) {
            XCTFail("Inbox button did not appear in time")
        }
        app.staticTexts["InboxNavLink"].tap()

        hideSidebar(app)

        if !app.staticTexts["Inbox"].waitForExistence(timeout: 2) {
            XCTFail("Inbox title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "inbox-empty")
    }
}
