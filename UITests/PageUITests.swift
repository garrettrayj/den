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
    @MainActor
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
    
    @MainActor
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
        
        let pageLink = app.staticTexts.matching(identifier: "SidebarPage").element(boundBy: 0)
        if !pageLink.waitForExistence(timeout: 2) {
            XCTFail("Page button did not appear in time")
        }
        pageLink.tap()

        hideSidebar(app)

        if !app.staticTexts["No Feeds"].waitForExistence(timeout: 2) {
            XCTFail("Page title did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "page-empty")
    }

    @MainActor
    func testPageGroupedLayout() throws {
        let app = launchApp(inMemory: false)

        app.staticTexts.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        
        hideSidebar(app)
        
        #if os(macOS)
        app.radioButtons["GroupedLayout"].tap()
        #else
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["GroupedLayout"].tap()
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "page-grouped-layout")
    }

    @MainActor
    func testPageTimelineLayout() throws {
        let app = launchApp(inMemory: false)

        app.staticTexts.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        
        hideSidebar(app)
        
        #if os(macOS)
        app.radioButtons["TimelineLayout"].tap()
        #else
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["TimelineLayout"].tap()
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "page-timeline-layout")
    }

    @MainActor
    func testPageDeckLayout() throws {
        let app = launchApp(inMemory: false)

        app.staticTexts.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        
        hideSidebar(app)

        #if os(macOS)
        app.radioButtons["DeckLayout"].tap()
        #else
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["DeckLayout"].tap()
        #endif

        sleep(3)

        attachScreenshot(of: app.windows.firstMatch, named: "page-deck-layout")
    }
}
