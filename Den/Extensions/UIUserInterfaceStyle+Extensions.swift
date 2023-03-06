//
//  UIUserInterfaceStyle+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 3/5/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

extension UIUserInterfaceStyle {
    var name: String? {
        switch self {
        case .unspecified:
            return nil
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        @unknown default:
            return nil
        }
    }
}
