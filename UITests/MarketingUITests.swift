//
//  MarketingUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

/*
final class MarketingUITests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app?.terminate()
    }

    func testScreenshots() {
        if !app.buttons["create-profile-button"].waitForExistence(timeout: 30) {
            XCTFail("Create profile button did not appear in time")
        }
        app.buttons["create-profile-button"].tap()

        if !app.staticTexts["Get Started"].waitForExistence(timeout: 5) {
            XCTFail("Get Started message does not exist")
        }
        app.buttons["load-demo-button"].tap()

        // Refresh/load feeds
        let profileRefreshButton = app.buttons["refresh-button"].firstMatch
        profileRefreshButton.tap()
        expectation(for: NSPredicate(format: "enabled == 1"), evaluatedWith: profileRefreshButton, handler: nil)
        waitForExpectations(timeout: 120, handler: nil)
        
        takeScreenshot(named: "01-Welcome")
        
        // Inbox
        app.buttons["inbox-button"].tap()
        #if os(iOS)
        if XCUIDevice.shared.orientation == .portrait && UIDevice.current.userInterfaceIdiom == .pad {
            app.tap()
        }
        #endif
        takeScreenshot(named: "02-Inbox")
        #if os(iOS)
        if XCUIDevice.shared.orientation == .portrait && UIDevice.current.userInterfaceIdiom == .pad {
            app.buttons["ToggleSidebar"].tap()
        }
        #endif
        
        // Trending
        app.buttons["trending-button"].tap()
        #if os(iOS)
        if XCUIDevice.shared.orientation == .portrait && UIDevice.current.userInterfaceIdiom == .pad {
            app.tap()
        }
        #endif
        takeScreenshot(named: "03-Trending")
        #if os(iOS)
        if XCUIDevice.shared.orientation == .portrait && UIDevice.current.userInterfaceIdiom == .pad {
            app.buttons["ToggleSidebar"].tap()
        }
        #endif
        
        // Navigate to page
        app.buttons["Space"].tap()
        #if os(iOS)
        if XCUIDevice.shared.orientation == .portrait && UIDevice.current.userInterfaceIdiom == .pad {
            app.tap()
        }
        #endif
        
        // Item view
        app.buttons.matching(identifier: "gadget-item-button").element(boundBy: 1).firstMatch.tap()
        takeScreenshot(named: "04-Item")
        goBack()
        if !app.staticTexts["Space"].waitForExistence(timeout: 2) {
            XCTFail("Page header did not appear in time")
        }
        
        // Page layouts
        takeScreenshot(named: "05-GroupedLayout")

        app.buttons["page-layout-picker"].tap()
        app.buttons["showcase-layout-option"].tap()
        app.buttons["page-layout-picker"].tap()
        takeScreenshot(named: "06-ShowcaseLayout")
        
        app.buttons["page-layout-picker"].tap()
        app.buttons["deck-layout-option"].tap()
        takeScreenshot(named: "07-DeckLayout")

        // Page settings
        app.buttons["page-settings-button"].tap()
        takeScreenshot(named: "08-PageSettings")

        app.navigationBars.buttons["cancel-button"].tap()

        app.buttons["page-layout-picker"].tap()
        app.buttons["grouped-layout-option"].tap()

        // Feed view
        app.buttons["feed-button"].firstMatch.tap()
        takeScreenshot(named: "09-FeedView")

        // Feed settings
        app.buttons["feed-settings-button"].tap()
        sleep(2)
        takeScreenshot(named: "06-FeedSettings")
        app.navigationBars.buttons["cancel-button"].tap()

        // Settings
        app.buttons["app-menu"].tap()
        app.buttons["settings-button"].tap()
        sleep(2)
        takeScreenshot(named: "07-Settings")
        app.navigationBars.buttons["close-button"].tap()

        // Search
        let searchField = app.searchFields["Search"]
        searchField.tap()
        searchField.typeText("NASA")
        searchField.typeText("\n")
        sleep(4)
        takeScreenshot(named: "08-Search")
    }
    
    func goBack() {
        let backButton = app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 0)
        if !backButton.waitForExistence(timeout: 2) {
            XCTFail("Item back button did not appear in time.")
        }
        backButton.tap()
    }
    
    func takeScreenshot(named name: String) {
        // Take the screenshot
        let screenshot = app.windows.firstMatch.screenshot()

        // Create a new attachment to save our screenshot
        // and give it a name consisting of the "named"
        // parameter and the device name, so we can find
        // it later.
        let screenshotAttachment = XCTAttachment(
            uniformTypeIdentifier: "public.png",
            name: "\(name).png",
            payload: screenshot.pngRepresentation,
            userInfo: nil
        )

        // Usually Xcode will delete attachments after
        // the test has run; we don't want that!
        screenshotAttachment.lifetime = .keepAlways

        // Add the attachment to the test log,
        // so we can retrieve it later
        add(screenshotAttachment)
    }
}
*/
