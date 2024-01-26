//
//  BackgroundSeparatorShapeStyle.swift
//  Den
//
//  Created by Garrett Johnson on 1/12/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BackgroundSeparatorShapeStyle: ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        if environment.colorScheme == .light {
            return Color.gray.opacity(0.3)
        } else {
            return Color.black.opacity(0.5)
        }
    }
}
