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
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
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
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular {
                app.tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif
        
        if !app.staticTexts["Diagnostics"].waitForExistence(timeout: 2) {
            XCTFail("Diagnostics header did not appear in time")
        }
        
        attachScreenshot(of: app.windows.firstMatch, named: "Diagnostics")
    }
    
    func testDiagnosticsEmpty() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()

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
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular {
                app.tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.tap()
            }
        }
        #endif
        
        if !app.staticTexts["Diagnostics"].waitForExistence(timeout: 2) {
            XCTFail("Diagnostics header did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "Diagnostics")
    }
}
