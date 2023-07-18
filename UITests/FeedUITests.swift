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
        app.launch()
        
        app.buttons["Space"].tap()
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad && XCUIDevice.shared.orientation == .portrait {
            app.tap()
        }
        #endif
        app.buttons["feed-button"].firstMatch.tap()
        
        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "FeedViewCompressed"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.terminate()
    }
    
    func testFeedSettings() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Space"].tap()
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad && XCUIDevice.shared.orientation == .portrait {
            app.tap()
        }
        #endif
        app.buttons["feed-button"].firstMatch.tap()
        
        app.buttons["feed-settings-button"].firstMatch.tap()
        
        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "FeedSettings"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.terminate()
    }
    
    func testFeedViewExpanded() throws {
        
    }
    
    func testFeedViewNoData() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.buttons["load-demo-button"].tap()
        app.buttons["Space"].tap()
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad && XCUIDevice.shared.orientation == .portrait {
            app.tap()
        }
        #endif
        app.buttons["feed-button"].firstMatch.tap()

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "FeedViewNoData"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.terminate()
    }
}
