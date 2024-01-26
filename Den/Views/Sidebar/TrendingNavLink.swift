//
//  TrendingNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendingNavLink: View {
    @ObservedObject var profile: Profile

    var body: some View {
        Label {
            WithTrends(profile: profile) { trends in
                Text("Trending", comment: "Button label.")
                    .lineLimit(1)
                    .badge(trends.containingUnread().count)
            }
        } icon: {
            Image(systemName: "chart.line.uptrend.xyaxis")
        }
        .tag(DetailPanel.trending)
        .accessibilityIdentifier("TrendingNavLink")
    }
}
