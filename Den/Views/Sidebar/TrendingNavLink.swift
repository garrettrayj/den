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
    
    @EnvironmentObject private var dataController: DataController
    
    var body: some View {
        WithTrends { trends in
            Label {
                Text("Trending", comment: "Button label.")
            } icon: {
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
            .badge(showUnreadCounts ? trends.containingUnread.count : 0)
            .tag(DetailPanel.trending)
            .accessibilityIdentifier("TrendingNavLink")
            .contextMenu {
                MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                    HistoryUtility.toggleRead(
                        container: dataController.container,
                        items: trends.items
                    )
                }
            }
        }
    }
}
