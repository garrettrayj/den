//
//  ScreenshotTest.swift
//  DenScreenshots
//
//  Created by Garrett Johnson on 7/30/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import XCTest

enum ScreenshotTestError: Error {
    case deviceIdiomError(String)
}

class ScreenshotTestCase: XCTestCase {
    var targetIdiom: UIUserInterfaceIdiom { .unspecified }
    var app: XCUIApplication!

    let demoPages: [String] = [
        "World News",
        "US News",
        "Technology",
        "Business",
        "Science",
        "Space",
        "Funnies",
        "Curiosity",
        "Gaming",
        "TV & Movies",
        "Music"
    ]
    let existsPredicate = NSPredicate(format: "exists == 1")
    let notExistsPredicate = NSPredicate(format: "exists == 0")

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        let currentDevice = UIDevice.current.userInterfaceIdiom

        #if targetEnvironment(macCatalyst)
        if targetIdiom != .mac {
            throw XCTSkip("Incompatible device type")
        }
        #else
        if currentDevice != targetIdiom {
            throw XCTSkip("Incompatible device type")
        }
        #endif

        // Initialize the application
        app = XCUIApplication()

        // We send a command line argument to our app, to enable it to reset its state
        app.launchArguments.append("--reset")
        app.launch()

        #if !targetEnvironment(macCatalyst)
        if targetIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeRight
        }
        #endif

    }

    override func tearDownWithError() throws {
        app?.terminate()
    }

    func takeScreenshot(named name: String) {
        // Take the screenshot
        let fullScreenshot = XCUIScreen.main.screenshot()

        // Create a new attachment to save our screenshot
        // and give it a name consisting of the "named"
        // parameter and the device name, so we can find
        // it later.
        let screenshotAttachment = XCTAttachment(
            uniformTypeIdentifier: "public.png",
            name: "\(name).png",
            payload: fullScreenshot.pngRepresentation,
            userInfo: nil
        )

        // Usually Xcode will delete attachments after
        // the test has run; we don't want that!
        screenshotAttachment.lifetime = .keepAlways

        // Add the attachment to the test log,
        // so we can retrieve it later
        add(screenshotAttachment)
    }
}
