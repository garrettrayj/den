//
//  RefreshProgressViewStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct RefreshProgressViewStyle: ProgressViewStyle {
    @ObservedObject var profile: Profile

    func makeBody(configuration: Configuration) -> some View {
        if let fractionCompleted = configuration.fractionCompleted {
            VStack {
                if fractionCompleted < 1.0 {
                    Text(
                        """
                        \(Int(fractionCompleted * Double(profile.feedCount))) \
                        of \(profile.feedCount) Updated
                        """,
                        comment: "Status message."
                    )
                    .monospacedDigit()
                } else {
                    Text("Analyzing…", comment: "Status message.")
                }

                #if os(iOS)
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule()
                        .fill(.tint)
                        .frame(width: fractionCompleted * 120)
                }
                .frame(height: 6)
                .frame(width: 120)
                #endif
            }
        }
    }
}
