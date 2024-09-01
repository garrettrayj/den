//
//  XCUIDevice+Extensions.swift
//  UITests
//
//  Created by Garrett Johnson on 7/18/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import XCTest

extension XCUIDevice.Appearance {
    var name: String {
        switch self {
        case .unspecified:
            "Unspecified"
        case .light:
            "Light"
        case .dark:
            "Dark"
        @unknown default:
            "Default"
        }
    }
}
