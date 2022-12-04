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

    #if targetEnvironment(macCatalyst)
    let spacing: CGFloat = 4
    #else
    let spacing: CGFloat = 6
    #endif

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: spacing) {
            HStack {
                if let completed = configuration.fractionCompleted, completed < 1.0 {
                    // Updating feeds
                    configuration.currentValueLabel
                    Text("Updated")
                } else {
                    // Performing analysis
                    Text("Analyzing")
                }
            }
            .lineLimit(1)
            .monospacedDigit()
            .padding(.horizontal, 8)

            ZStack(alignment: .leading) {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(width: geometry.size.width, height: height)
                        .foregroundColor(Color(UIColor.tertiarySystemFill))

                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(
                            width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width,
                            height: height
                        )
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}
