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

    #if targetEnvironment(macCatalyst)
    let spacing: CGFloat = 4
    #else
    let spacing: CGFloat = 6
    #endif

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: spacing) {
            HStack(spacing: 0) {
                if progress.completedUnitCount < progress.totalUnitCount + 1 {
                    // Updating feeds
                    Text("\(progress.completedUnitCount) of \(progress.totalUnitCount) updated")
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
            }
            #if targetEnvironment(macCatalyst)
            .frame(width: 108)
            #else
            .frame(width: 124)
            #endif
        }
        .frame(maxWidth: .infinity)
    }
}
