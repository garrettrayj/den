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

    @Binding var hideRead: Bool

    var body: some View {
        if trend.managedObjectContext == nil {
            SplashNote(title: "Trend Deleted", symbol: "slash.circle")
        } else {
            WithItems(scopeObject: trend) { items in
                TrendLayout(
                    trend: trend,
                    profile: profile,
                    hideRead: hideRead,
                    items: items.visibilityFiltered(hideRead ? false : nil)
                )
                .background(GroupedBackground())
                .toolbar {
                    TrendBottomBar(
                        trend: trend,
                        profile: profile,
                        hideRead: $hideRead,
                        items: items
                    )
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
