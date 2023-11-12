//
//  PageUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

final class PageUITests: UITestCase {
    func testNewPage() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()
        app.buttons["CreateProfile"].firstMatch.tap()

        #if os(macOS)
        if !app.outlines.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }
        app.outlines.buttons["NewPage"].tap()
        #else
        if !app.collectionViews.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }
        app.collectionViews.buttons["NewPage"].tap()
        #endif
        
        attachScreenshot(of: app.windows.firstMatch, named: "new-page")
    }
    
    func testPageEmpty() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()
        app.buttons["CreateProfile"].firstMatch.tap()

        #if os(macOS)
        if !app.outlines.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }
        app.outlines.buttons["NewPage"].tap()
        #else
        if !app.collectionViews.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }
        app.collectionViews.buttons["NewPage"].tap()
        #endif
        
        app.buttons["CreatePage"].tap()
        
        #if os(macOS)
        if !app.buttons["PageNavLink"].waitForExistence(timeout: 2) {
            XCTFail("Page button did not appear in time")
        }
        app.buttons["PageNavLink"].firstMatch.tap()
        #else
        if !app.collectionViews.buttons["Untitled"].waitForExistence(timeout: 2) {
            XCTFail("Page button did not appear in time")
        }
        app.collectionViews.buttons["Untitled"].tap()
        #endif

        hideSidebar(app)

        if !app.staticTexts["No Feeds"].waitForExistence(timeout: 2) {
            XCTFail("Page title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "page-empty")
    }

    func testPageGroupedLayout() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        #else
        app.staticTexts["Science"].tap()
        #endif
        
        hideSidebar(app)
        
        #if os(macOS)
        app.toolbars.popUpButtons.element(boundBy: 1).tap()
        app.menuItems["GroupedLayout"].tap()
        #else
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["GroupedLayout"].tap()
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "PageGroupedLayout")
    }

    func testPageTimelineLayout() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        #else
        app.staticTexts["Science"].tap()
        #endif
        
        hideSidebar(app)

        #if os(macOS)
        app.toolbars.popUpButtons.element(boundBy: 1).tap()
        app.menuItems["TimelineLayout"].tap()
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
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        #else
        app.staticTexts["Science"].tap()
        #endif
        
        hideSidebar(app)

        #if os(macOS)
        app.toolbars.popUpButtons.element(boundBy: 1).tap()
        app.menuItems["DeckLayout"].tap()
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
        app.buttons.matching(identifier: "PageNavLink").element(boundBy: 4).tap()
        #else
        app.staticTexts["Science"].tap()
        #endif
        
        hideSidebar(app)

        if !app.buttons["ToggleInspector"].waitForExistence(timeout: 2) {
            XCTFail("Page inspector button did not appear in time")
        }

        app.buttons["ToggleInspector"].firstMatch.tap()

        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "PageInspector")
    }
}
