//
//  RefreshProgressViewStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RefreshProgressViewStyle: ProgressViewStyle {
    @ObservedObject var profile: Profile

    var feedCount: Int {
        profile.feedsArray.count
    }

    func makeBody(configuration: Configuration) -> some View {
        if let fractionCompleted = configuration.fractionCompleted {
            VStack {
                if fractionCompleted < 1.0 {
                    Text(
                        "\(Int(fractionCompleted * Double(feedCount))) of \(feedCount) Updated",
                        comment: "Status message."
                    )
                    .monospacedDigit()
                } else {
                    Text("Analyzing…", comment: "Status message.")
                }

                #if os(iOS)
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.quaternary)
                        Capsule()
                            .fill(.tint)
                            .frame(width: fractionCompleted * geometry.size.width)
                    }
                    .frame(height: 6)
                }.frame(width: 132)
                #endif
            }
        }
    }
}
