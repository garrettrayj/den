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

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    #if os(macOS)
    func testShowGeneralAppSettings() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        if !app.staticTexts["General"].waitForExistence(timeout: 2) {
            XCTFail("General settings tab did not appear in time")
        }
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "AppSettingsGeneralTab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testShowProfilesAppSettings() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        app.buttons["ProfilesTab"].tap()
        if !app.staticTexts["Profiles"].waitForExistence(timeout: 2) {
            XCTFail("Profiles settings tab did not appear in time")
        }
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "AppSettingsProfilesTab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    #else
    func testShowAppSettings() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.buttons["app-menu"].tap()
        app.buttons["settings-button"].tap()
        if !app.buttons["close-button"].waitForExistence(timeout: 2) {
            XCTFail("Settings sheet did not appear in time")
        }
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "AppSettings"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.terminate()
    }
    #endif
}
