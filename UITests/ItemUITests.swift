//
//  ItemUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class ItemUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testItemView() throws {
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
        
        app.buttons["ItemAction"].firstMatch.tap()
        
        sleep(3)

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "ItemView"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
