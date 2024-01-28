//
//  InboxUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import XCTest

final class InboxUITests: UITestCase {
    func testInbox() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

        app.staticTexts["InboxNavLink"].tap()

        hideSidebar(app)

        if !app.staticTexts["Inbox"].waitForExistence(timeout: 2) {
            XCTFail("Inbox title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "inbox")
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
