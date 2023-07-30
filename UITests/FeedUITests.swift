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
        app.outlines["Sidebar"].cells.element(boundBy: 10).tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 6).tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 8).tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.tap()
            }
        }
        #endif

        app.buttons["FeedNavLink"].firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "FeedViewCompressed")
    }

    func testFeedConfiguration() throws {
        let app = launchApp(inMemory: false)

        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.outlines["Sidebar"].cells.element(boundBy: 10).tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 6).tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 8).tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.tap()
            }
        }
        #endif

        app.buttons["FeedNavLink"].firstMatch.tap()

        #if os(iOS)
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["FeedMenu"].tap()
        }
        #endif

        if !app.buttons["ConfigureFeed"].waitForExistence(timeout: 2) {
            XCTFail("Configure feed button did not appear in time")
        }

        app.buttons["ConfigureFeed"].firstMatch.tap()

        if !app.staticTexts["Feed Configuration"].waitForExistence(timeout: 2) {
            XCTFail("Feed configuration title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "FeedConfiguration")
    }

    func testFeedViewNoData() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()

        app.buttons["LoadDemo"].tap()

        #if os(macOS)
        app.outlines["Sidebar"].cells.element(boundBy: 10).tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 6).tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 8).tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.tap()
            }
        }
        #endif

        app.buttons["FeedNavLink"].firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "FeedViewNoData")
    }
}
