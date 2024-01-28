//
//  OrganizerUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import XCTest

final class OrganizerUITests: UITestCase {
    func testOrganizer() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.popUpButtons["SidebarMenu"].tap()
        app.menuItems["Organizer"].tap()
        #else
        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].tap()
        app.buttons["Organizer"].tap()
        #endif

        #if os(macOS)
        app.buttons["Hide Sidebar"].firstMatch.tap()
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

        if !app.staticTexts["Organizer"].waitForExistence(timeout: 2) {
            XCTFail("Organizer header did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "organizer")
    }

    func testOrganizerEmpty() throws {
        let app = launchApp(inMemory: true)

        if !app.buttons["NewProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["NewProfile"].firstMatch.tap()
        app.buttons["CreateProfile"].firstMatch.tap()

        #if os(macOS)
        if !app.outlines.buttons["NewPage"].waitForExistence(timeout: 2) {
            XCTFail("New Page button did not appear in time")
        }
        app.outlines.buttons["NewPage"].tap()
        app.buttons["CreatePage"].tap()
        app.popUpButtons["SidebarMenu"].tap()
        app.menuItems["Organizer"].tap()
        #else
        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].tap()
        app.buttons["Organizer"].tap()
        #endif

        #if os(macOS)
        app.buttons["Hide Sidebar"].firstMatch.tap()
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

        if !app.staticTexts["Organizer"].waitForExistence(timeout: 2) {
            XCTFail("Organizer header did not appear in time")
        }

        attachScreenshot(of: app.windows.firstMatch, named: "organizer-empty")
    }
    
    func testOrganizerInfo() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.popUpButtons["SidebarMenu"].tap()
        app.menuItems["Organizer"].tap()
        #else
        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].tap()
        app.buttons["Organizer"].tap()
        #endif

        hideSidebar(app)

        #if os(macOS)
        app.tables["OrganizerList"].staticTexts["TIME"].tap()
        #else
        app.collectionViews["OrganizerList"].staticTexts["TIME"].tap()
        app.buttons["ToggleInspector"].tap()
        #endif

        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "organizer-info")
    }
    
    func testOrganizerConfig() throws {
        let app = launchApp(inMemory: false)
        app.buttons["SelectProfile"].firstMatch.tap()

        #if os(macOS)
        app.popUpButtons["SidebarMenu"].tap()
        app.menuItems["Organizer"].tap()
        #else
        if !app.buttons["SidebarMenu"].waitForExistence(timeout: 2) {
            XCTFail("Sidebar menu button did not appear in time")
        }
        app.buttons["SidebarMenu"].tap()
        if !app.buttons["Organizer"].waitForExistence(timeout: 2) {
            XCTFail("Organizer button did not appear in time")
        }
        app.buttons["Organizer"].tap()
        #endif

        hideSidebar(app)
        
        #if os(macOS)
        app.tables["OrganizerList"].staticTexts["TIME"].tap()
        app.radioButtons["OrganizerConfig"].tap()
        #else
        app.collectionViews["OrganizerList"].staticTexts["TIME"].tap()
        app.buttons["ToggleInspector"].tap()
        app.buttons["OrganizerConfig"].tap()
        #endif
        
        sleep(2)

        attachScreenshot(of: app.windows.firstMatch, named: "organizer-config")
    }
}
