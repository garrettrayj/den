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
    @ObservedObject var profile: Profile

    @Binding var detailPanel: DetailPanel?
    @Binding var refreshing: Bool
    @Binding var path: NavigationPath
    @Binding var showingNewFeedSheet: Bool

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                switch detailPanel ?? .welcome {
                case .inbox:
                    Inbox(profile: profile, showingNewFeedSheet: $showingNewFeedSheet)
                case .organizer:
                    Organizer(profile: profile)
                case .page(let page):
                    PageView(page: page, profile: profile, showingNewFeedSheet: $showingNewFeedSheet)
                case .search(let search):
                    SearchView(profile: profile, search: search)
                case .trending:
                    Trending(profile: profile)
                case .welcome:
                    Welcome(profile: profile)
                }
            }
            .disabled(refreshing)
            .navigationDestination(for: SubDetailPanel.self) { panel in
                ZStack {
                    switch panel {
                    case .feed(let feed):
                        FeedView(feed: feed)
                    case .item(let item):
                        ItemView(item: item, profile: profile)
                    case .trend(let trend):
                        TrendView(trend: trend)
                    }
                }
                .disabled(refreshing)
            }
        }
    }
}
