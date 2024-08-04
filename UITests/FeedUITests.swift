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
    @MainActor
    func testFeedViewCompressed() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.disclosureTriangles.element(boundBy: 3).tap()
        app.textFields.matching(identifier: "SidebarFeed").firstMatch.tap()
        #else
        app.collectionViews["Sidebar"].cells.element(boundBy: 7)
            .buttons.allElementsBoundByIndex.last?.tap()
        let sidebarFeed = app.staticTexts.matching(identifier: "SidebarFeed").firstMatch
        if !sidebarFeed.waitForExistence(timeout: 3) {
            XCTFail("Feed nav link did not appear in time")
        }
        sidebarFeed.tap()
        #endif
        
        hideSidebar(app)

        #if os(macOS)
        if !app.staticTexts["Futurity"].waitForExistence(timeout: 2) {
            XCTFail("Feed title did not appear in time")
        }
        #else
        if !app.buttons["Futurity"].waitForExistence(timeout: 2) {
            XCTFail("Feed title did not appear in time")
        }
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "feed-view-compressed")
    }
    
    @MainActor
    func testFeedViewExpanded() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.disclosureTriangles.element(boundBy: 3).tap()
        app.textFields.matching(identifier: "SidebarFeed").firstMatch.tap()
        #else
        app.collectionViews["Sidebar"].cells.element(boundBy: 7)
            .buttons.allElementsBoundByIndex.last?.tap()
        let sidebarFeed = app.staticTexts.matching(identifier: "SidebarFeed").firstMatch
        if !sidebarFeed.waitForExistence(timeout: 3) {
            XCTFail("Feed nav link did not appear in time")
        }
        sidebarFeed.tap()
        #endif

        hideSidebar(app)

        #if os(macOS)
        if !app.staticTexts["Futurity"].waitForExistence(timeout: 2) {
            XCTFail("Feed title did not appear in time")
        }
        #else
        if !app.buttons["Futurity"].waitForExistence(timeout: 3) {
            XCTFail("Feed title did not appear in time")
        }
        #endif

        #if os(macOS)
        app.buttons["ToggleInspector"].firstMatch.tap()
        app.switches["LargePreviews"].tap()
        app.buttons["ToggleInspector"].firstMatch.tap()
        #else
        app.buttons["ToggleInspector"].tap()
        app.switches["LargePreviews"].switches.firstMatch.tap()
        app.buttons["ToggleInspector"].forceTap()
        #endif

        sleep(2)
        attachScreenshot(of: app.windows.firstMatch, named: "feed-view-expanded")
        
        #if os(macOS)
        app.buttons["ToggleInspector"].firstMatch.tap()
        app.switches["LargePreviews"].tap()
        #else
        app.buttons["ToggleInspector"].forceTap()
        app.switches["LargePreviews"].switches.firstMatch.tap()
        #endif
    }

    @MainActor
    func testFeedInspector() throws {
        let app = launchApp(inMemory: false)

        #if os(macOS)
        app.disclosureTriangles.element(boundBy: 3).tap()
        app.textFields.matching(identifier: "SidebarFeed").firstMatch.tap()
        #else
        app.collectionViews["Sidebar"].cells.element(boundBy: 7)
            .buttons.allElementsBoundByIndex.last?.tap()
        let sidebarFeed = app.staticTexts.matching(identifier: "SidebarFeed").firstMatch
        if !sidebarFeed.waitForExistence(timeout: 3) {
            XCTFail("Feed nav link did not appear in time")
        }
        sidebarFeed.tap()
        #endif

        hideSidebar(app)

        if !app.buttons["ToggleInspector"].waitForExistence(timeout: 2) {
            XCTFail("Feed options button did not appear in time")
        }

        app.buttons["ToggleInspector"].firstMatch.tap()

        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "feed-inspector")
    }

    @MainActor
    func testFeedViewNoData() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["LoadDemo"].waitForExistence(timeout: 2) {
            XCTFail("Load Demo button did not appear in time")
        }
        app.buttons["LoadDemo"].tap()

        #if os(macOS)
        app.disclosureTriangles.element(boundBy: 3).tap()
        app.textFields.matching(identifier: "SidebarFeed").firstMatch.tap()
        #else
        app.collectionViews["Sidebar"].cells.element(boundBy: 7)
            .buttons.allElementsBoundByIndex.last?.tap()
        let sidebarFeed = app.staticTexts.matching(identifier: "SidebarFeed").firstMatch
        if !sidebarFeed.waitForExistence(timeout: 3) {
            XCTFail("Feed nav link did not appear in time")
        }
        sidebarFeed.tap()
        #endif

        hideSidebar(app)

        attachScreenshot(of: app.windows.firstMatch, named: "feed-no-data")
    }
}
