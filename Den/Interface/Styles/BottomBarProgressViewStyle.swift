//
//  BottomBarProgressViewStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BottomBarProgressViewStyle: ProgressViewStyle {
    let height: CGFloat = 4
    let width: CGFloat = 120

    #if targetEnvironment(macCatalyst)
    let spacing: CGFloat = 4
    #else
    let spacing: CGFloat = 6
    #endif

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: spacing) {
            HStack {
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
