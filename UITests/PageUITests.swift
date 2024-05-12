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
    func testNewPage() throws {
        let app = launchApp(inMemory: true)

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
        if !app.textFields["SidebarPage"].waitForExistence(timeout: 2) {
            XCTFail("Page button did not appear in time")
        }
        app.textFields["SidebarPage"].firstMatch.tap()
        #else
        if !app.collectionViews.staticTexts["Untitled"].waitForExistence(timeout: 2) {
            XCTFail("Page button did not appear in time")
        }
        app.collectionViews.staticTexts["Untitled"].tap()
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
        app.textFields["Science"].tap()
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

        attachScreenshot(of: app.windows.firstMatch, named: "page-grouped-layout")
    }

    func testPageTimelineLayout() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields["Science"].tap()
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

        attachScreenshot(of: app.windows.firstMatch, named: "page-timeline-layout")
    }

    func testPageDeckLayout() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.textFields["Science"].tap()
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

        attachScreenshot(of: app.windows.firstMatch, named: "page-deck-layout")
    }
}
