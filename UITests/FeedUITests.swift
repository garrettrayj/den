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

final class FeedUITests: UITestCase {
    func testFeedViewCompressed() throws {
        let app = launchApp(inMemory: false)

        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.buttons["Space"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.buttons["Space"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.buttons["Space"].tap()
            }
        } else {
            app.buttons["Space"].tap()
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif

        app.buttons["FeedNavLink"].firstMatch.tap()

        if !app.staticTexts["Universe Today"].waitForExistence(timeout: 2) {
            XCTFail("Feed title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "05-FeedViewCompressed")
    }

    func testFeedOptions() throws {
        let app = launchApp(inMemory: false)

        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.buttons["Space"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.buttons["Space"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.buttons["Space"].tap()
            }
        } else {
            app.buttons["Space"].tap()
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif

        app.buttons["FeedNavLink"].firstMatch.tap()

        #if os(iOS)
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["FeedMenu"].forceTap()
        }
        #endif

        if !app.buttons["FeedOptions"].waitForExistence(timeout: 2) {
            XCTFail("Feed options button did not appear in time")
        }

        app.buttons["FeedOptions"].firstMatch.tap()

        if !app.staticTexts["Feed Options"].waitForExistence(timeout: 2) {
            XCTFail("Feed options title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "06-FeedOptions")
    }

    func testFeedViewNoData() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()

        app.buttons["LoadDemo"].tap()

        #if os(macOS)
        app.buttons["Space"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.buttons["Space"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.buttons["Space"].tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["Space"].tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.buttons["Space"].tap()
                app.tap()
            }
        }
        #endif

        app.buttons["FeedNavLink"].firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "FeedViewNoData")
    }
}
