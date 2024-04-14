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
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    
    var body: some View {
        Label {
            if showUnreadCounts {
                WithTrends(readFilter: false) { trends in
                    Text("Trending", comment: "Button label.").badge(trends.count)
                }
            } else {
                Text("Trending", comment: "Button label.")
            }
        } icon: {
            Image(systemName: "chart.line.uptrend.xyaxis")
        }
        .lineLimit(1)
        .tag(DetailPanel.trending)
        .accessibilityIdentifier("TrendingNavLink")
    }
}
