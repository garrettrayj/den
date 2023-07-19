//
//  XCTestCase+Extensions.swift
//  UITests
//
//  Created by Garrett Johnson on 7/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

extension XCTestCase {
    func attachScreenshot(of element: XCUIElement, named name: String) {
        let orientation = XCUIDevice.shared.orientation.name
        let appearance = XCUIDevice.shared.appearance.name
        let locale = Locale.autoupdatingCurrent.identifier
        
        let attachment = XCTAttachment(screenshot: element.screenshot())
        attachment.name = "\(locale)/\(appearance)/\(orientation)/\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

