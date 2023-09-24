//
//  PageUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class PageUITests: UITestCase {
    func testPageEmpty() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()
        app.buttons["CreateProfile"].firstMatch.tap()

        app.buttons["NewPage"].tap()
        app.buttons["CreatePage"].tap()

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

        if !app.staticTexts["Untitled"].waitForExistence(timeout: 2) {
            XCTFail("Page title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "PageEmpty")
    }

    func testPageSpreadLayout() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields["Space"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.staticTexts["Space"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.staticTexts["Space"].tap()
            }
        } else {
            app.staticTexts["Space"].tap()
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "PageSpreadLayout")
    }

    func testPageTimelineLayout() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields["Space"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.staticTexts["Space"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.staticTexts["Space"].tap()
            }
        } else {
            app.staticTexts["Space"].tap()
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif

        #if os(macOS)
        app.radioButtons["TimelineLayout"].tap()
        #else
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["PageMenu"].forceTap()
        } else {
            app.buttons["PageLayoutPicker"].tap()
        }
        app.buttons["TimelineLayout"].tap()
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "02-PageTimelineLayout")
    }

    func testPageDeckLayout() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields["Space"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.staticTexts["Space"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.staticTexts["Space"].tap()
            }
        } else {
            app.staticTexts["Space"].tap()
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif

        #if os(macOS)
        app.radioButtons["DeckLayout"].tap()
        #else
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["PageMenu"].forceTap()
        } else {
            app.buttons["PageLayoutPicker"].tap()
        }
        app.buttons["DeckLayout"].tap()
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "03-PageDeckLayout")
    }

    func testPageOptions() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields["Space"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.staticTexts["Space"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.staticTexts["Space"].tap()
            }
        } else {
            app.staticTexts["Space"].tap()
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif

        #if os(iOS)
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["PageMenu"].forceTap()
        }
        #endif

        if !app.buttons["ToggleInspector"].waitForExistence(timeout: 2) {
            XCTFail("Page inspector button did not appear in time")
        }

        app.buttons["ToggleInspector"].firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "04-PageInspector")
    }
}
