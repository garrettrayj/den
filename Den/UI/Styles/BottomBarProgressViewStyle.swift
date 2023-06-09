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
    @ObservedObject var profile: Profile

    var feedCount: Int {
        profile.feedsArray.count
    }

    let height: CGFloat = 4

    #if targetEnvironment(macCatalyst)
    let spacing: CGFloat = 4
    #else
    let spacing: CGFloat = 6
    #endif

    func makeBody(configuration: Configuration) -> some View {
        if let fractionCompleted = configuration.fractionCompleted {
            VStack(spacing: spacing) {
                if fractionCompleted < 1.0 {
                    Text(
                        "\(Int(fractionCompleted * Double(feedCount))) of \(feedCount) Updated",
                        comment: "Refresh in-progress label."
                    )
                        .monospacedDigit()
                } else {
                    Text("Analyzing…", comment: "Tend calculations in-progress label.")
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.quaternary)
                        Capsule()
                            .fill(.tint)
                            .frame(width: (CGFloat(configuration.fractionCompleted ?? 0) > 1 ? 1 :
                                            CGFloat(configuration.fractionCompleted ?? 0)) * geometry.size.width)
                    }
                    .frame(height: height)
                }.frame(maxWidth: 120)
            }
            .font(.caption)
        }
    }
}
