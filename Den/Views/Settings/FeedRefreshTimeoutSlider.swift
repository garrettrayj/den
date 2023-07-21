//
//  FeedRefreshTimeoutSlider.swift
//  Den
//
//  Created by Garrett Johnson on 7/5/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedRefreshTimeoutSlider: View {
    @Binding var feedRefreshTimeout: Int

    @State private var duration: Double = 0

    var body: some View {
        Slider(
            value: $duration,
            in: 10...300,
            label: {
                FeedRefreshTimeoutLabel(feedRefreshTimeout: $feedRefreshTimeout)
            }
        )
        .onChange(of: duration) { _ in
            feedRefreshTimeout = Int(duration)
        }
        .task {
            duration = Double(feedRefreshTimeout)
        }
    }
}
