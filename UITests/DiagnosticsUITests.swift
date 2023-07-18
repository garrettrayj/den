//
//  DiagnosticsUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class DiagnosticsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDiagnostics() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        #if os(macOS)
        app.popUpButtons["AppMenu"].tap()
        app.menuItems["Diagnostics"].tap()
        #else
        app.buttons["AppMenu"].forceTap()
        app.buttons["Diagnostics"].tap()
        #endif
        
        #if os(iOS)
        app.tap()
        #endif
        
        if !app.staticTexts["Diagnostics"].waitForExistence(timeout: 2) {
            XCTFail("Diagnostics header did not appear in time")
        }

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "Diagnostics"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testDiagnosticsEmpty() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["CreateProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        #if os(macOS)
        app.popUpButtons["AppMenu"].tap()
        app.menuItems["Diagnostics"].tap()
        #else
        app.buttons["AppMenu"].forceTap()
        app.buttons["Diagnostics"].tap()
        #endif
        
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.tap()
        }
        #endif
        
        if !app.staticTexts["Diagnostics"].waitForExistence(timeout: 2) {
            XCTFail("Diagnostics header did not appear in time")
        }

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "DiagnosticsEmpty"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
