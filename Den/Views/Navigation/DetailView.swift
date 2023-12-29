//
//  DetailView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson
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
                case .inbox:
                    Inbox(profile: profile, hideRead: $hideRead, searchQuery: $searchQuery)
                case .organizer:
                    Organizer(profile: profile)
                case .page(let page):
                    PageView(page: page, hideRead: $hideRead, searchQuery: $searchQuery)
                case .tag(let tag):
                    TagView(tag: tag)
                case .trending:
                    Trending(profile: profile, hideRead: $hideRead)
                case .welcome:
                    Welcome(profile: profile)
                }
            }
            .navigationDestination(for: SubDetailPanel.self) { panel in
                switch panel {
                case .bookmark(let bookmark):
                    BookmarkView(bookmark: bookmark)
                case .feed(let feed):
                    FeedView(feed: feed, hideRead: $hideRead)
                case .item(let item):
                    ItemView(item: item)
                case .trend(let trend):
                    TrendView(trend: trend, hideRead: $hideRead)
                }
            }
        }
    }
}
