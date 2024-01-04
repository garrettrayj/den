//
//  TrendingNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct TrendingNavLink: View {
    @ObservedObject var profile: Profile

    var body: some View {
        Label {
            Text("Trending", comment: "Button label.")
                .lineLimit(1)
                .badge(profile.trends.containingUnread().count)
        } icon: {
            Image(systemName: "chart.line.uptrend.xyaxis")
        }
        .tag(DetailPanel.trending)
        .accessibilityIdentifier("TrendingNavLink")
    }
}
