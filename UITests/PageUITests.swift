//
//  PageUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class PageUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPageEmpty() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        if !app.buttons["CreateProfile"].waitForExistence(timeout: 2) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["CreateProfile"].tap()
        
        app.buttons["NewPage"].tap()
        app.buttons["PageNavLink"].firstMatch.tap()
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            if XCUIDevice.shared.orientation.isPortrait {
                app.tap()
            } else {
                app.buttons["ToggleSidebar"].tap()
            }
        }
        #endif

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "PageEmpty"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testPageGroupedLayout() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        app.buttons["Space"].tap()
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            if XCUIDevice.shared.orientation.isPortrait {
                app.tap()
            } else {
                app.buttons["ToggleSidebar"].tap()
            }
        }
        #endif

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "PageGroupedLayout"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testPageTimelineLayout() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        app.buttons["Space"].firstMatch.tap()
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            if XCUIDevice.shared.orientation.isPortrait {
                app.tap()
            } else {
                app.buttons["ToggleSidebar"].tap()
            }
        }
        #endif
        
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["TimelineLayout"].tap()

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "PageTimelineLayout"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testPageShowcaseLayout() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        app.buttons["Space"].firstMatch.tap()
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            if XCUIDevice.shared.orientation.isPortrait {
                app.tap()
            } else {
                app.buttons["ToggleSidebar"].tap()
            }
        }
        #endif
        
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["ShowcaseLayout"].tap()

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "PageShowcaseLayout"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testPageDeckLayout() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        app.buttons["Space"].firstMatch.tap()
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            if XCUIDevice.shared.orientation.isPortrait {
                app.tap()
            } else {
                app.buttons["ToggleSidebar"].tap()
            }
        }
        #endif
        
        app.buttons["PageLayoutPicker"].tap()
        app.buttons["DeckLayout"].tap()

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "PageDeckLayout"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testPageSettings() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        app.buttons["Space"].firstMatch.tap()
        
        #if os(macOS)
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            if XCUIDevice.shared.orientation.isPortrait {
                app.tap()
            } else {
                app.buttons["ToggleSidebar"].tap()
            }
        }
        #endif
        
        app.buttons["ShowPageSettings"].tap()

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "PageSettings"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
