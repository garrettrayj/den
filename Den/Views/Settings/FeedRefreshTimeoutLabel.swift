//
//  FeedRefreshTimeoutLabel.swift
//  Den
//
//  Created by Garrett Johnson on 7/5/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedRefreshTimeoutLabel: View {
    @Binding var feedRefreshTimeout: Double
    
    var duration: Duration {
        .init(secondsComponent: Int64(feedRefreshTimeout), attosecondsComponent: 0)
    }

    var body: some View {
        Text(
            "Request Timeout: \(duration.formatted(.time(pattern: .minuteSecond)))",
            comment: "Slider label."
        )
        .lineLimit(1)
    }
}

