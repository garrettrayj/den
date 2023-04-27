//
//  TrendView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendView: View {
    @ObservedObject var trend: Trend
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    var body: some View {
        VStack {
            if trend.managedObjectContext == nil {
                SplashNote(title: "Trend Deleted", symbol: "slash.circle")
            } else {
                TrendLayout(trend: trend, profile: profile, hideRead: hideRead)
                    .background(GroupedBackground())
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            TrendBottomBar(
                                trend: trend,
                                profile: profile,
                                refreshing: $refreshing,
                                hideRead: $hideRead
                            )
                        }
                    }
                    .navigationTitle(trend.wrappedTitle)
                    .navigationDestination(for: DetailPanel.self) { detailPanel in
                        switch detailPanel {
                        case .feed(let feed):
                            FeedView(
                                feed: feed,
                                profile: profile,
                                hideRead: $hideRead
                            )
                        case .item(let item):
                            ItemView(item: item, profile: profile)
                        }
                    }
            }
        }
    }
}
