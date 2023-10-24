//
//  PageUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
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

        if !app.outlineRows.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }

        app.outlineRows.buttons["NewPage"].tap()
        app.buttons["CreatePage"].tap()
        
        #if os(macOS)
        if !app.outlineRows.textFields["Untitled"].waitForExistence(timeout: 2) {
            XCTFail("Page button did not appear in time")
        }
        app.outlineRows.textFields["Untitled"].tap()
        #else
        if !app.collectionViews.buttons["Untitled"].waitForExistence(timeout: 2) {
            XCTFail("Page button did not appear in time")
        }
        app.collectionViews.buttons["Untitled"].tap()
        #endif

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

        if !app.staticTexts["No Feeds"].waitForExistence(timeout: 2) {
            XCTFail("Page title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "PageEmpty")
    }

    func testPageGroupedLayout() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields["Science"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.staticTexts["Science"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.staticTexts["Science"].tap()
            }
        } else {
            app.staticTexts["Science"].tap()
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

        #if os(macOS)
        app.textFields["Science"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.staticTexts["Science"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.staticTexts["Science"].tap()
            }
        } else {
            app.staticTexts["Science"].tap()
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
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["TimelineLayout"].tap()
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "PageTimelineLayout")
    }

    func testPageDeckLayout() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields["Science"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.staticTexts["Science"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.staticTexts["Science"].tap()
            }
        } else {
            app.staticTexts["Science"].tap()
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
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["DeckLayout"].tap()
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "PageDeckLayout")
    }

    func testPageInspector() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields["Science"].tap()
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.staticTexts["Science"].tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.staticTexts["Science"].tap()
            }
        } else {
            app.staticTexts["Science"].tap()
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif

        if !app.buttons["ToggleInspector"].waitForExistence(timeout: 2) {
            XCTFail("Page inspector button did not appear in time")
        }

        app.buttons["ToggleInspector"].firstMatch.tap()

        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "PageInspector")
    }
}
