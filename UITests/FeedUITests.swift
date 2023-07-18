//
//  FeedUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class FeedUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testFeedViewCompressed() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        if !app.buttons["Space"].waitForExistence(timeout: 2) {
            XCTFail("Space page nav link did not appear in time")
        }
        app.buttons["Space"].tap()
        #if os(iOS)
        app.tap()
        #endif
        app.buttons["FeedNavLink"].firstMatch.tap()
        
        sleep(3)
        
        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "FeedViewCompressed"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testFeedSettings() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        app.buttons["Space"].tap()
        
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
        
        app.buttons["FeedNavLink"].firstMatch.tap()
        
        app.buttons["ShowFeedSettings"].firstMatch.tap()
        
        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "FeedSettings"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testFeedViewNoData() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.buttons["LoadDemo"].tap()
        app.buttons["Space"].tap()
        
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
        
        app.buttons["FeedNavLink"].firstMatch.tap()

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "FeedViewNoData"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
