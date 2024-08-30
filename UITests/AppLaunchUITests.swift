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
    @MainActor
    func testPosterScreenshot() throws {
        let app = launchApp(inMemory: false)

        if !app.staticTexts["InboxNavLink"].waitForExistence(timeout: 10) {
            XCTFail("Inbox button did not appear in time")
        }

        #if os(macOS)
        app.disclosureTriangles.element(boundBy: 3).tap()
        app.staticTexts.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.collectionViews["Sidebar"].cells.element(boundBy: 7).buttons.firstMatch.tap()
            app.staticTexts.matching(identifier: "SidebarPage").element(boundBy: 3).tap()
        } else {
            app.collectionViews["Sidebar"]
                .cells
                .element(boundBy: 7)
                .buttons
                .element(boundBy: 1)
                .tap()
        }
        #endif

        // Wait for images to load
        sleep(8)

        attachScreenshot(of: app.windows.firstMatch, named: "app-poster")
    }
}
