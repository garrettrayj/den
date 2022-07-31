//
//  BottomBarProgressStyle.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BottomBarProgressStyle: ProgressViewStyle {
    let height: CGFloat = 4
    let width: CGFloat = 136
    let progress: Progress

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 6) {
            HStack(spacing: 0) {
                if progress.completedUnitCount < progress.totalUnitCount - 1 {
                    // Updating feeds
                    Text("Updating \(progress.completedUnitCount) of \(progress.totalUnitCount - 1)…")
                } else {
                    // Performing analysis
                    Text("Analyzing trends…")
                }
            }
            .lineLimit(1)
            .monospacedDigit()

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
            }
        }
    }
}
