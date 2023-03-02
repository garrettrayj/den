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
    let height: CGFloat = 4

    #if targetEnvironment(macCatalyst)
    let spacing: CGFloat = 4
    #else
    let spacing: CGFloat = 6
    #endif

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: spacing) {
            HStack(spacing: 0) {
                if let completed = configuration.fractionCompleted, completed < 1.0 {
                    configuration.currentValueLabel
                    Text(" Updated")
                } else {
                    Text("Analyzing")
                }
            }
            .font(.caption).monospacedDigit()

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(UIColor.systemFill))
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width)
                }.frame(height: height)
            }
        }
    }
}
