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
    @Binding var detailPanel: DetailPanel?
    @Binding var path: NavigationPath
    @Binding var searchQuery: String

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                switch detailPanel ?? .welcome {
                case .bookmarks:
                    Bookmarks()
                case .feed(let feed):
                    FeedView(feed: feed).id(feed)
                case .inbox:
                    Inbox()
                case .organizer:
                    Organizer()
                case .page(let page):
                    PageView(page: page).id(page)
                case .search:
                    SearchView(searchQuery: $searchQuery)
                case .trending:
                    Trending()
                case .welcome:
                    Welcome()
                }
            }
            .navigationDestination(for: SubDetailPanel.self) { panel in
                switch panel {
                case .bookmark(let bookmark):
                    BookmarkView(bookmark: bookmark).id(bookmark)
                case .feed(let feed):
                    FeedView(feed: feed).id(feed)
                case .item(let item):
                    ItemView(item: item).id(item)
                case .trend(let trend):
                    TrendView(trend: trend).id(trend)
                }
            }
        }
    }
}
