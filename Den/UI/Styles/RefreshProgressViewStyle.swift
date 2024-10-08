//
//  RefreshProgressViewStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct RefreshProgressViewStyle: ProgressViewStyle {
    let feedCount: Int

    func makeBody(configuration: Configuration) -> some View {
        if let fractionCompleted = configuration.fractionCompleted {
            VStack {
                if fractionCompleted < 1.0 {
                    Text(
                        """
                        \(Int(fractionCompleted * Double(feedCount))) \
                        of \(feedCount) Updated
                        """,
                        comment: "Status message (refresh in progress)."
                    )
                    .monospacedDigit()
                } else {
                    Text("Analyzing…", comment: "Status message (analysis in progress).")
                }

                #if os(iOS)
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule()
                        .fill(.tint)
                        .frame(width: fractionCompleted * 132)
                }
                .frame(width: 132, height: 6)
                #endif
            }
        }
    }
}
