//
//  AppSettingsUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class AppSettingsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    #if os(macOS)
    func testAppSettingsGeneralTab() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        if !app.staticTexts["General"].waitForExistence(timeout: 2) {
            XCTFail("General settings tab did not appear in time")
        }
        
        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "AppSettingsGeneralTab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testAppSettingsProfilesTab() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        
        app.buttons["Profiles"].tap()
        
        if !app.staticTexts["Profiles"].waitForExistence(timeout: 2) {
            XCTFail("Profiles settings tab did not appear in time")
        }
        
        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "AppSettingsProfilesTab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    #else
    func testAppSettingsSheet() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        if !app.buttons["CreateProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()

        app.buttons["AppMenu"].forceTap()
        app.buttons["Settings"].tap()
        if !app.buttons["Close"].waitForExistence(timeout: 2) {
            XCTFail("Settings sheet did not appear in time")
        }
        
        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "AppSettings"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    #endif
}
