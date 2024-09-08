//
//  TrendingNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendingNavLink: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.showUnreadCounts) private var showUnreadCounts

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
                    HistoryUtility.toggleRead(items: trends.items, context: viewContext)
                }
            }
        }
    }
}
