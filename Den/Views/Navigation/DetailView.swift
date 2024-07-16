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
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var detailPanel: DetailPanel?
    @Binding var hideRead: Bool
    @Binding var path: NavigationPath
    @Binding var searchQuery: String

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                switch detailPanel ?? .welcome {
                case .bookmarks:
                    Bookmarks()
                case .feed(let objectURL):
                    if
                        let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(
                            forURIRepresentation: objectURL
                        ),
                        let feed = viewContext.object(with: objectID) as? Feed
                    {
                        FeedView(feed: feed, hideRead: $hideRead).id(objectURL)
                    }
                case .inbox:
                    Inbox(hideRead: $hideRead)
                case .organizer:
                    Organizer()
                case .page(let objectURL):
                    if
                        let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(
                            forURIRepresentation: objectURL
                        ),
                        let page = viewContext.object(with: objectID) as? Page
                    {
                        PageView(page: page, hideRead: $hideRead).id(objectURL)
                    }
                case .search:
                    SearchView(hideRead: $hideRead, searchQuery: $searchQuery)
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
