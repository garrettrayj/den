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
    @Binding var hideRead: Bool
    @Binding var refreshing: Bool
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                switch detailPanel ?? .welcome {
                case .inbox:
                    Inbox(profile: profile, hideRead: $hideRead)
                case .organizer:
                    Organizer(profile: profile)
                case .page(let page):
                    PageView(
                        page: page,
                        profile: profile,
                        hideRead: $hideRead
                    )
                case .search(let search):
                    SearchView(profile: profile, search: search, hideRead: $hideRead)
                case .tag(let tag):
                    TagView(profile: profile, tag: tag)
                case .trending:
                    Trending(profile: profile, hideRead: $hideRead)
                case .welcome:
                    Welcome(profile: profile)
                }
            }
            .disabled(refreshing)
            .navigationDestination(for: SubDetailPanel.self) { panel in
                ZStack {
                    switch panel {
                    case .bookmark(let bookmark):
                        BookmarkView(bookmark: bookmark)
                    case .feed(let feed):
                        FeedView(feed: feed, hideRead: $hideRead)
                    case .item(let item):
                        ItemView(item: item, profile: profile)
                    case .trend(let trend):
                        TrendView(trend: trend, hideRead: $hideRead)
                    }
                }
                .disabled(refreshing)
            }
        }
    }
}
