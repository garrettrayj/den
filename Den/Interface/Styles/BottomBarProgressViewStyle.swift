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
    let width: CGFloat = 100
    #else
    let spacing: CGFloat = 6
    let width: CGFloat = 120
    #endif

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: spacing) {
            HStack(spacing: 4) {
                if let completed = configuration.fractionCompleted, completed < 1.0 {
                    configuration.currentValueLabel.monospacedDigit()
                    Text("Updated")
                } else {
                    Text("Analyzing")
                }
            }.font(.caption)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .frame(width: width, height: height)
                    .foregroundColor(Color(UIColor.tertiarySystemFill))

                RoundedRectangle(cornerRadius: height / 2)
                    .frame(
                        width: CGFloat(configuration.fractionCompleted ?? 0) * width,
                        height: height
                    )
                    .foregroundColor(.accentColor)
            }.frame(width: width)
        }
    }
}
