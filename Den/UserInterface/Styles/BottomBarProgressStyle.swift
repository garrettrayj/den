//
//  BottomBarProgressStyle.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BottomBarProgressStyle: ProgressViewStyle {
    let progress: Progress
    let height: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 6) {
            HStack(spacing: 0) {
                if progress.completedUnitCount < progress.totalUnitCount {
                    // Updating feeds
                    Text("Updating \(progress.completedUnitCount) of \(progress.totalUnitCount - 1)")
                } else {
                    // Performing analysis
                    Text("Analyzing")
                }
            }
            .lineLimit(1)
            .monospacedDigit()

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

            }.frame(maxWidth: 144)
        }
        .frame(maxWidth: .infinity)
    }
}
