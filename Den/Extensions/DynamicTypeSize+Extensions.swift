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
    var fontScale: CGFloat {
        var fontScale = 1.0

        switch self {
        case .xSmall:
            fontScale = 0.882758620689655
        case .small:
            fontScale = 0.937931034482759
        case .medium:
            fontScale = 1.0
        case .large:
            fontScale = 1.0448275862069
        case .xLarge:
            fontScale = 1.16551724137931
        case .xxLarge:
            fontScale = 1.24827586206897
        case .xxxLarge:
            fontScale = 1.36551724137931
        case .accessibility1:
            fontScale = 1.64137931034483
        case .accessibility2:
            fontScale = 1.93793103448276
        case .accessibility3:
            fontScale = 2.33793103448276
        case .accessibility4:
            fontScale = 2.77931034482759
        case .accessibility5:
            fontScale = 2.99310344827586
        default:
            fontScale = 1
        }

        return fontScale
    }
}
