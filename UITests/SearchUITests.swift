//
//  SearchUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class SearchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testSearch() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        #if os(iOS)
        app.swipeDown()
        #endif
        
        let searchField = app.searchFields["Search"].firstMatch
        searchField.tap()
        searchField.typeText("NASA")
        searchField.typeText("\n")
        
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
        attachment.name = "Search"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testSearchEmpty() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["CreateProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        #if os(iOS)
        app.swipeDown()
        #endif
        
        let searchField = app.searchFields["Search"].firstMatch
        searchField.tap()
        searchField.typeText("Example")
        searchField.typeText("\n")
        
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
        attachment.name = "SearchNoResults"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
