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
    @Binding var path: NavigationPath
    @Binding var searchQuery: String

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                switch detailPanel ?? .welcome {
                case .feed(let feed):
                    FeedView(feed: feed, profile: profile, hideRead: $hideRead).id(feed)
                case .inbox:
                    Inbox(profile: profile, hideRead: $hideRead).id(profile)
                case .organizer:
                    Organizer(profile: profile).id(profile)
                case .page(let page):
                    PageView(page: page, hideRead: $hideRead).id(page)
                case .search:
                    SearchView(profile: profile, hideRead: $hideRead, searchQuery: $searchQuery)
                        .id(profile)
                case .tag(let tag):
                    TagView(tag: tag).id(tag)
                case .trending:
                    Trending(profile: profile, hideRead: $hideRead).id(profile)
                case .welcome:
                    Welcome(profile: profile).id(profile)
                }
            }
            .navigationDestination(for: SubDetailPanel.self) { panel in
                switch panel {
                case .bookmark(let bookmark):
                    BookmarkView(bookmark: bookmark).id(bookmark)
                case .feed(let feed):
                    FeedView(feed: feed, profile: profile, hideRead: $hideRead).id(feed)
                case .item(let item):
                    ItemView(item: item).id(item)
                case .trend(let trend):
                    TrendView(profile: profile, trend: trend, hideRead: $hideRead).id(trend)
                }
            }
        }
    }
}
