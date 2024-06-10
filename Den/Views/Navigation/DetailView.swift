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
    
    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                switch detailPanel ?? .welcome {
                case .feed(let feed):
                    FeedView(feed: feed, hideRead: $hideRead).id(feed)
                case .inbox:
                    Inbox(hideRead: $hideRead)
                case .organizer:
                    Organizer()
                case .page(let page):
                    PageView(page: page, hideRead: $hideRead).id(page)
                case .search:
                    SearchView(hideRead: $hideRead, searchQuery: $searchQuery)
                case .tag(let tag):
                    TagView(tag: tag).id(tag)
                case .trending:
                    Trending(hideRead: $hideRead)
                case .welcome:
                    Welcome()
                }
            }
            .navigationDestination(for: SubDetailPanel.self) { panel in
                switch panel {
                case .bookmark(let bookmark):
                    BookmarkView(bookmark: bookmark).id(bookmark)
                case .feed(let feed):
                    FeedView(feed: feed, hideRead: $hideRead).id(feed)
                case .item(let item):
                    ItemView(item: item).id(item)
                case .trend(let trend):
                    TrendView(trend: trend, hideRead: $hideRead).id(trend)
                }
            }
        }
    }
}
