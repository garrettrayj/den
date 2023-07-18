//
//  SearchUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class SearchUITests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testSearchEmpty() throws {
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
        app.swipeDown()
        #endif
        let searchField = app.searchFields["Search"].firstMatch
        searchField.tap()
        searchField.typeText("Example")
        searchField.typeText("\n")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "SearchNoResults"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.terminate()
    }
}
