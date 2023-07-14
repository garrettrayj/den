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

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /*
    func testLaunchCreateProfileButton() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-in-memory")
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        if !app.buttons["create-profile-button"].waitForExistence(timeout: 20) {
            XCTFail("Create Profile button did not appear in time")
        }

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "LaunchNoProfiles"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.terminate()
    }
     */
}
