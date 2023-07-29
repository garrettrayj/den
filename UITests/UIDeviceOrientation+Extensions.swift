//
//  UIDeviceOrientation+Extensions.swift
//  UITests
//
//  Created by Garrett Johnson on 7/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import XCTest

#if os(iOS)
extension UIDeviceOrientation {
    var name: String {
        switch self {
        case .unknown:
            "Unknown"
        case .portrait:
            "Portrait"
        case .portraitUpsideDown:
            "PortraitUpsideDown"
        case .landscapeLeft:
            "LandscapeLeft"
        case .landscapeRight:
            "LandscapeRight"
        case .faceUp:
            "FaceUp"
        case .faceDown:
            "FaceDown"
        @unknown default:
            "Default"
        }
    }
}
#endif
