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

    func testGetStartedNewPage() throws {
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

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "PageEmpty"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
