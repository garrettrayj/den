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
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
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

        attachScreenshot(of: app.windows.firstMatch, named: "PageEmpty")
    }
    
    func testPageGroupedLayout() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        #if os(macOS)
        app.outlines["Sidebar"].cells.element(boundBy: 10).tap()
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular && app.windows.firstMatch.verticalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 6).tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 8).tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.tap()
            }
        }
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "PageGroupedLayout")
    }
    
    func testPageTimelineLayout() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
                
        #if os(macOS)
        app.outlines["Sidebar"].cells.element(boundBy: 10).tap()
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular && app.windows.firstMatch.verticalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 6).tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 8).tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.tap()
            }
        }
        #endif
        
        #if os(macOS)
        app.radioButtons["TimelineLayout"].tap()
        #else
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["PageMenu"].tap()
        } else {
            app.buttons["PageLayoutPicker"].tap()
        }
        app.buttons["TimelineLayout"].tap()
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "PageTimelineLayout")
    }
    
    func testPageShowcaseLayout() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        #if os(macOS)
        app.outlines["Sidebar"].cells.element(boundBy: 10).tap()
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular && app.windows.firstMatch.verticalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 6).tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 8).tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.tap()
            }
        }
        #endif
        
        #if os(macOS)
        app.radioButtons["ShowcaseLayout"].tap()
        #else
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["PageMenu"].tap()
        } else {
            app.buttons["PageLayoutPicker"].tap()
        }
        app.buttons["ShowcaseLayout"].tap()
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "PageShowcaseLayout")
    }
    
    func testPageDeckLayout() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        #if os(macOS)
        app.outlines["Sidebar"].cells.element(boundBy: 10).tap()
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular && app.windows.firstMatch.verticalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 6).tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 8).tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.tap()
            }
        }
        #endif
        
        #if os(macOS)
        app.radioButtons["DeckLayout"].tap()
        #else
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["PageMenu"].tap()
        } else {
            app.buttons["PageLayoutPicker"].tap()
        }
        app.buttons["DeckLayout"].tap()
        #endif

        attachScreenshot(of: app.windows.firstMatch, named: "PageDeckLayout")
    }
    
    func testPageSettings() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-disable-cloud")
        app.launch()
        
        #if os(macOS)
        app.outlines["Sidebar"].cells.element(boundBy: 10).tap()
        app.buttons["Toggle Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular && app.windows.firstMatch.verticalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 6).tap()
                app.tap()
            } else if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.collectionViews["Sidebar"].cells.element(boundBy: 8).tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.collectionViews.firstMatch.cells.element(boundBy: 8).tap()
                app.tap()
            }
        }
        #endif
        
        #if os(iOS)
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            app.buttons["PageMenu"].tap()
        }
        #endif
        
        app.buttons["ConfigurePage"].firstMatch.tap()

        attachScreenshot(of: app.windows.firstMatch, named: "PageConfiguration")
    }
}
