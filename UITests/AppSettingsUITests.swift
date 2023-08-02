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
    func testAppSettings() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()

        app.menuBarItems["Den"].menuItems["Settings…"].tap()
        if !app.staticTexts["General"].waitForExistence(timeout: 2) {
            XCTFail("General settings tab did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "AppSettingsGeneralTab")
    }
    #endif
}
