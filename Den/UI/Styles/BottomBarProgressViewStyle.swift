//
//  BottomBarProgressViewStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BottomBarProgressViewStyle: ProgressViewStyle {
    var height: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(.quaternary)
                Capsule()
                    .fill(.tint)
                    .frame(width: (CGFloat(configuration.fractionCompleted ?? 0) > 1 ? 1 :
                                    CGFloat(configuration.fractionCompleted ?? 0)) * geometry.size.width)
            }
        }
        .frame(height: height)
        .frame(maxWidth: 100)
    }
}
