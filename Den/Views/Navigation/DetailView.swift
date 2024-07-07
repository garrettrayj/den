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
    @Environment(\.modelContext) private var modelContext
    
    @Binding var detailPanel: DetailPanel?
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                switch detailPanel ?? .welcome {
                case .bookmarks:
                    Bookmarks()
                case .feed(let persistentModelID):
                    if let feed = modelContext.model(for: persistentModelID) as? Feed {
                        FeedView(feed: feed).id(feed)
                    }
                case .inbox:
                    Inbox()
                case .organizer:
                    Organizer()
                case .page(let persistentModelID):
                    if let page = modelContext.model(for: persistentModelID) as? Page {
                        PageView(page: page).id(page)
                    }
                case .search:
                    SearchView()
                case .trending:
                    Trending()
                case .welcome:
                    Welcome()
                }
            }
            .navigationDestination(for: SubDetailPanel.self) { panel in
                switch panel {
                case .bookmark(let persistentModelID):
                    if let bookmark = modelContext.model(for: persistentModelID) as? Bookmark {
                        BookmarkView(bookmark: bookmark).id(bookmark)
                    }
                case .feed(let persistentModelID):
                    if let feed = modelContext.model(for: persistentModelID) as? Feed {
                        FeedView(feed: feed).id(feed)
                    }
                case .item(let persistentModelID):
                    if let item = modelContext.model(for: persistentModelID) as? Item {
                        ItemView(item: item).id(item)
                    }
                case .trend(let persistentModelID):
                    if let trend = modelContext.model(for: persistentModelID) as? Trend {
                        TrendView(trend: trend).id(trend)
                    }
                }
            }
        }
    }
}
