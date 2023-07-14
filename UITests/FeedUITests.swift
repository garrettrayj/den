//
//  FeedUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class FeedUITests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testFeedNoData() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["create-profile-button"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }
        app.buttons["create-profile-button"].tap()
        
        app.buttons["load-demo-button"].tap()
        app.buttons["Space"].tap()
        #if os(iOS)
        app.tap()
        #endif
        app.buttons["feed-button"].firstMatch.tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "FeedEmpty"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.terminate()
    }
}
