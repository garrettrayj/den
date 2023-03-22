//
//  DynamicTypeSize+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 2/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

extension DynamicTypeSize {
    var layoutScalingFactor: CGFloat {
        switch self {
        case .xSmall:
            return 0.882
        case .small:
            return 0.937
        case .medium:
            return 1.0
        case .large:
            return 1.044
        case .xLarge:
            return 1.165
        case .xxLarge:
            return 1.248
        case .xxxLarge:
            return 1.365
        case .accessibility1:
            return 1.641
        case .accessibility2:
            return 1.937
        case .accessibility3:
            return 2.337
        case .accessibility4:
            return 2.779
        case .accessibility5:
            return 2.993
        default:
            return 1.0
        }
    }
}
