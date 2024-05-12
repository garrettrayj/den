//
//  AppLaunchUITests.swift
//  UITests
//
//  Created by Garrett Johnson on 7/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

final class AppLaunchUITests: UITestCase {
    func testPosterScreenshot() throws {
        let app = launchApp(inMemory: false)

        if !app.staticTexts["InboxNavLink"].waitForExistence(timeout: 10) {
            XCTFail("Inbox button did not appear in time")
        }

        #if os(macOS)
        app.disclosureTriangles.element(boundBy: 3).tap()
        app.textFields.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        #else
        app.collectionViews["Sidebar"].cells.element(boundBy: 6).buttons.firstMatch.tap()
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.staticTexts["Science"].tap()
        }
        #endif

        // Wait for images to load
        sleep(8)

        attachScreenshot(of: app.windows.firstMatch, named: "app-poster")
    }
}
