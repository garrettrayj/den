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
    @Binding var feedRefreshTimeout: Double

    var body: some View {
        Slider(
            value: $feedRefreshTimeout,
            in: 10...300,
            label: {
                FeedRefreshTimeoutLabel(feedRefreshTimeout: $feedRefreshTimeout)
            }
        )
    }
}
