//
//  TrendsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct TrendsView: View {
    @Environment(\.persistentContainer) private var container

    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var body: some View {
        GeometryReader { geometry in
            if profile.trends.isEmpty {
                StatusBoxView(
                    message: Text("No Trends Available"),
                    caption: Text("Could not find any common organizations, people, or places in titles"),
                    symbol: "questionmark.folder"
                )
            } else {
                if visibleTrends.isEmpty {
                    AllReadStatusView(hiddenItemCount: readTrends.count)
                } else {
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: visibleTrends) { trend in
                            TrendBlockView(trend: trend, refreshing: $refreshing)
                        }
                        .modifier(TopLevelBoardPaddingModifier())
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Trends")
        .navigationDestination(for: TrendPanel.self) { detailPanel in
            switch detailPanel {
            case .trend(let trend):
                TrendView(
                    trend: trend,
                    unreadCount: trend.items.unread().count,
                    hideRead: $hideRead,
                    refreshing: $refreshing
                )
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                TrendsBottomBarView(
                    profile: profile,
                    hideRead: $hideRead,
                    refreshing: $refreshing,
                    unreadCount: profile.trends.unread().count
                )
            }
        }
    }

    private var readTrends: [Trend] {
        profile.trends.filter { trend in
            trend.items.unread().isEmpty
        }
    }

    private var visibleTrends: [Trend] {
        profile.trends.filter { trend in
            hideRead ? !trend.items.unread().isEmpty : true
        }
    }
}
