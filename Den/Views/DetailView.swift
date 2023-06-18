//
//  DetailView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DetailView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var contentSelection: DetailPanel?
    @Binding var searchQuery: String

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                switch contentSelection ?? .welcome {
                case .welcome:
                    Welcome(profile: profile, refreshing: $refreshManager.refreshing)
                case .search:
                    Search(profile: profile, hideRead: $hideRead, query: searchQuery)
                case .inbox:
                    Inbox(profile: profile, hideRead: $hideRead)
                case .trending:
                    Trending(profile: profile, hideRead: $hideRead)
                case .page(let page):
                    PageView(
                        page: page,
                        profile: profile,
                        hideRead: $hideRead
                    )
                }
            }
            .background(GroupedBackground())
            .disabled(refreshManager.refreshing)
            .navigationDestination(for: SubDetailPanel.self) { panel in
                ZStack {
                    switch panel {
                    case .feed(let feed):
                        FeedView(
                            feed: feed,
                            profile: profile,
                            hideRead: $hideRead
                        )
                    case .item(let item):
                        if let feed = item.feedData?.feed {
                            ItemView(item: item, feed: feed, profile: profile)
                        }
                    case .trend(let trend):
                        TrendView(trend: trend, profile: profile, hideRead: $hideRead)
                    }
                }
                .background(GroupedBackground())
                .disabled(refreshManager.refreshing)
            }
        }
    }
}
