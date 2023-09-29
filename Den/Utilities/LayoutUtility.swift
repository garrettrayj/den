//
//  LayoutUtility.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

struct LayoutUtility {
    static func numColumns(width: CGFloat, layoutScalingFactor: Double) -> Int {
        let adjustedWidth = width / layoutScalingFactor
        return max(1, Int((adjustedWidth / log2(adjustedWidth)) / 30))
    }
}
