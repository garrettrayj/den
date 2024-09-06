//
//  TrendingNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendingNavLink: View {
    @Environment(\.showUnreadCounts) private var showUnreadCounts

    var body: some View {
        WithTrendsUnreadCount { unreadCount in
            Label {
                Text("Trending", comment: "Button label.")
                    .badge(showUnreadCounts ? unreadCount : 0)
            } icon: {
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
            .tag(DetailPanel.trending)
            .accessibilityIdentifier("TrendingNavLink")
        }
    }
}
