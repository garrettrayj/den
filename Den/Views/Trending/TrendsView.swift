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
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

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
                            TrendBlockView(trend: trend)
                        }
                        .modifier(TopLevelBoardPaddingModifier())
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Trends")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                TrendsBottomBarView(
                    profile: profile,
                    hideRead: $hideRead,
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
