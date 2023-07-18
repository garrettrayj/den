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

final class InboxUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testInbox() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        app.buttons["InboxNavLink"].tap()
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            if XCUIDevice.shared.orientation.isPortrait {
                app.tap()
            } else {
                app.buttons["ToggleSidebar"].tap()
            }
        }
        #endif

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "InboxEmpty"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testInboxEmpty() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.buttons["NewPage"].tap()
        
        app.buttons["InboxNavLink"].tap()
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            if XCUIDevice.shared.orientation.isPortrait {
                app.tap()
            } else {
                app.buttons["ToggleSidebar"].tap()
            }
        }
        #endif

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "InboxEmpty"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
