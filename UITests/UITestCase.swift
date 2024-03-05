//
//  UITestCase.swift
//  UITests
//
//  Created by Garrett Johnson on 7/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

class UITestCase: XCTestCase {
    let existsPredicate = NSPredicate(format: "exists == 1")
    let notExistsPredicate = NSPredicate(format: "exists == 0")
    let hittablePredicate = NSPredicate(format: "hittable == 1")
    let enabledPredicate = NSPredicate(format: "enabled == 1")

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func launchApp(inMemory: Bool) -> XCUIApplication {
        if ProcessInfo.processInfo.arguments.contains("-dark-appearance") {
            XCUIDevice.shared.appearance = .dark
        } else if ProcessInfo.processInfo.arguments.contains("-light-appearance") {
            XCUIDevice.shared.appearance = .light
        }

        #if os(iOS)
        if ProcessInfo.processInfo.arguments.contains("-landscape-orientation") {
            XCUIDevice.shared.orientation = .landscapeRight
        } else if ProcessInfo.processInfo.arguments.contains("-portrait-orientation") {
            XCUIDevice.shared.orientation = .portrait
        } else if ProcessInfo.processInfo.arguments.contains("-automatic-orientation") {

            let uiIdiom = UIDevice.current.userInterfaceIdiom
            if uiIdiom == .pad {
                XCUIDevice.shared.orientation = .landscapeRight
            } else if uiIdiom == .phone {
                XCUIDevice.shared.orientation = .portrait
            }
        }
        #endif

        let app = XCUIApplication()
        app.launchArguments = ProcessInfo.processInfo.arguments
        
        if inMemory {
            app.launchArguments.append("-in-memory")
        }

        app.launch()

        return app
    }

    func attachScreenshot(of element: XCUIElement, named name: String) {
        let appearance = XCUIDevice.shared.appearance.name
        let locale = Locale.current.identifier

        #if os(macOS)
        let name = "\(locale)+\(appearance)+\(name)"
        #else
        let orientation = XCUIDevice.shared.orientation.name
        let name = "\(locale)+\(appearance)+\(orientation)+\(name)"
        #endif

        let attachment = XCTAttachment(screenshot: element.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func hideSidebar(_ app: XCUIApplication) {
        #if os(macOS)
        app.buttons["Hide Sidebar"].firstMatch.tap()
        #else
        if UIDevice.current.userInterfaceIdiom == .phone {
            if app.windows.firstMatch.horizontalSizeClass == .regular &&
                app.windows.firstMatch.verticalSizeClass == .compact {
                app.tap()
            }
        } else {
            if XCUIDevice.shared.orientation.isLandscape {
                if app.buttons["ToggleSidebar"].exists {
                    app.buttons["ToggleSidebar"].tap()
                }
            } else {
                app.tap()
            }
        }
        #endif
    }
}
