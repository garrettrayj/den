//
//  FeedUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class FeedUITests: UITestCase {
    func testFeedViewCompressed() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
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

        app.buttons["FeedNavLink"].firstMatch.tap()

        if !app.staticTexts["Futurity"].waitForExistence(timeout: 2) {
            XCTFail("Feed title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "feed-view-compressed")
    }
    
    func testFeedViewExpanded() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        #else
        app.staticTexts["Science"].tap()
        #endif
        
        hideSidebar(app)

        app.buttons["FeedNavLink"].firstMatch.tap()

        if !app.staticTexts["Futurity"].waitForExistence(timeout: 2) {
            XCTFail("Feed title did not appear in time")
        }

        #if os(macOS)
        app.buttons["ToggleInspector"].firstMatch.tap()
        app.switches["LargePreviews"].tap()
        app.buttons["ToggleInspector"].firstMatch.tap()
        #else
        app.buttons["ToggleInspector"].tap()
        app.switches["LargePreviews"].switches.firstMatch.tap()
        app.buttons["ToggleInspector"].tap()
        #endif

        sleep(2)
        attachScreenshot(of: app.windows.firstMatch, named: "feed-view-expanded")
        
        #if os(macOS)
        app.buttons["ToggleInspector"].firstMatch.tap()
        app.switches["LargePreviews"].tap()
        #else
        app.buttons["ToggleInspector"].tap()
        app.switches["LargePreviews"].switches.firstMatch.tap()
        #endif
    }

    func testFeedInspector() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        #else
        app.staticTexts["Science"].tap()
        #endif
        
        hideSidebar(app)

        app.buttons["FeedNavLink"].firstMatch.tap()

        if !app.buttons["ToggleInspector"].waitForExistence(timeout: 2) {
            XCTFail("Feed options button did not appear in time")
        }

        app.buttons["ToggleInspector"].firstMatch.tap()

        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "feed-inspector")
    }

    func testFeedViewNoData() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()
        app.buttons["CreateProfile"].firstMatch.tap()

        if !app.buttons["LoadDemo"].waitForExistence(timeout: 2) {
            XCTFail("Load Demo button did not appear in time")
        }
        app.buttons["LoadDemo"].tap()

        #if os(macOS)
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        #else
        app.staticTexts["Science"].tap()
        #endif
        
        hideSidebar(app)

        app.buttons["FeedNavLink"].firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "feed-no-data")
    }
}
