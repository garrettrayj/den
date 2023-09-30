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

    @Binding var detailPanel: DetailPanel?
    
    var body: some View {
        Button {} label: {
            Label {
                Text("Trending", comment: "Button label.")
                    .lineLimit(1)
                    .badge(profile.trends.containingUnread().count)
            } icon: {
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
        }
        .buttonStyle(.plain)
        .tag(DetailPanel.trending)
        .accessibilityIdentifier("TrendingNavLink")
    }
}
