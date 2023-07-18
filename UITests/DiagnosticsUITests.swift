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
        app.launch()
        
        #if os(macOS)
        app.menuBarItems["Den"].menuItems["Diagnostics"].tap()
        if !app.staticTexts["Diagnostics"].waitForExistence(timeout: 2) {
            XCTFail("Diagnostics view did not appear in time")
        }
        #else
        app.buttons["app-menu"].tap()
        app.buttons["diagnostics-button"].tap()
        app.tap()
        #endif

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "Diagnostics"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testDiagnosticsEmpty() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["CreateProfile"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        #if os(iOS)
        app.buttons["app-menu"].tap()
        app.buttons["diagnostics-button"].tap()
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.tap()
        }
        #endif

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "DiagnosticsEmpty"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.terminate()
    }
}
