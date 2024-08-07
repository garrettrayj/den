//
//  ScreenshotsLaunchTests.swift
//  Screenshots
//
//  Created by Garrett Johnson on 8/6/24.
//  Copyright © 2024 
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class ScreenshotsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        snapshot("1Launch")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
