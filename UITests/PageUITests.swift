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

        app.buttons["NewPage"].tap()

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

    func testPageGroupedLayout() throws {
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

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "PageGroupedLayout")
    }

    func testPageTimelineLayout() throws {
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

    func testPageShowcaseLayout() throws {
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

        #if os(macOS)
        app.radioButtons["ShowcaseLayout"].tap()
        #else
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["PageMenu"].forceTap()
        } else {
            app.buttons["PageLayoutPicker"].tap()
        }
        app.buttons["ShowcaseLayout"].tap()
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "PageShowcaseLayout")
    }

    func testPageDeckLayout() throws {
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

    func testPageConfiguration() throws {
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

        #if os(iOS)
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["PageMenu"].forceTap()
        }
        #endif

        if !app.buttons["ConfigurePage"].waitForExistence(timeout: 2) {
            XCTFail("Configure page button did not appear in time")
        }

        app.buttons["ConfigurePage"].firstMatch.tap()

        if !app.staticTexts["Page Configuration"].waitForExistence(timeout: 2) {
            XCTFail("Page configuration title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "04-PageConfiguration")
    }
}
