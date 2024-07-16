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
                    if let feed = getObjectFromURL(url: objectURL) as? Feed {
                        FeedView(feed: feed, hideRead: $hideRead).id(objectURL)
                    }
                case .inbox:
                    Inbox(hideRead: $hideRead)
                case .organizer:
                    Organizer()
                case .page(let objectURL):
                    if let page = getObjectFromURL(url: objectURL) as? Page {
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
                case .bookmark(let objectURL):
                    if let bookmark = getObjectFromURL(url: objectURL) as? Bookmark {
                        BookmarkView(bookmark: bookmark).id(objectURL)
                    }
                case .feed(let objectURL):
                    if let feed = getObjectFromURL(url: objectURL) as? Feed {
                        FeedView(feed: feed, hideRead: $hideRead).id(objectURL)
                    }
                case .item(let objectURL):
                    if let item = getObjectFromURL(url: objectURL) as? Item {
                        ItemView(item: item).id(objectURL)
                    }
                case .trend(let objectURL):
                    if let trend = getObjectFromURL(url: objectURL) as? Trend {
                        TrendView(trend: trend, hideRead: $hideRead).id(objectURL)
                    }
                }
            }
        }
    }
    
    private func getObjectFromURL(url: URL) -> NSManagedObject? {
        guard let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(
            forURIRepresentation: url
        ) else { return nil }
        
        return viewContext.object(with: objectID)
    }
}
