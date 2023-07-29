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

final class AppSettingsUITests: UITestCase {
    #if os(macOS)
    func testAppSettingsGeneralTab() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].tap()

        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        if !app.staticTexts["General"].waitForExistence(timeout: 2) {
            XCTFail("General settings tab did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "AppSettingsGeneralTab")
    }

    func testAppSettingsProfilesTab() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].tap()

        app.menuBarItems["Den"].menuItems["Settings…"].tap()

        app.buttons["Profiles"].tap()

        if !app.staticTexts["Profiles"].waitForExistence(timeout: 2) {
            XCTFail("Profiles settings tab did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "AppSettingsProfilesTab")
    }
    #else
    func testAppSettingsSheet() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create profile button did not appear in time")
        }
        app.buttons["NewProfile"].tap()

        app.buttons["SidebarMenu"].forceTap()
        app.buttons["ShowProfileSettings"].tap()
        if !app.buttons["Cancel"].waitForExistence(timeout: 4) {
            XCTFail("Settings sheet did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "AppSettings")
    }
    #endif
}
