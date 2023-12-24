//
//  Inbox.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct Inbox: View {
    @ObservedObject var profile: Profile

    @SceneStorage("SearchQuery") private var searchQuery: String = ""

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        WithItems(
            scopeObject: profile,
            includeExtras: !searchQuery.isEmpty,
            searchQuery: searchQuery
        ) { items in
            Group {
                if profile.feedsArray.isEmpty {
                    NoFeeds(symbol: "tray")
                } else if !searchQuery.isEmpty && items.isEmpty {
                    NoSearchResults()
                } else if !searchQuery.isEmpty && items.unread().isEmpty && hideRead {
                    NoUnreadSearchResults()
                } else if items.isEmpty {
                    ContentUnavailable {
                        Label {
                            Text("Inbox Empty", comment: "Content unavailable title.")
                        } icon: {
                            Image(systemName: "tray")
                        }
                    } description: {
                        Text(
                            "Refresh to check for new items.",
                            comment: "Content unavailable description."
                        )
                    }
                } else if items.unread().isEmpty && hideRead {
                    AllRead(largeDisplay: true)
                } else {
                    GeometryReader { geometry in
                        ScrollView(.vertical) {
                            BoardView(
                                width: geometry.size.width,
                                list: items.visibilityFiltered(hideRead ? false : nil)
                            ) { item in
                                if let feed = item.feedData?.feed {
                                    if feed.wrappedPreviewStyle == .expanded {
                                        FeedItemExpanded(item: item, feed: feed)
                                    } else {
                                        FeedItemCompressed(item: item, feed: feed)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .modifier(SearchableModifier(searchQuery: $searchQuery))
            .toolbar {
                InboxToolbar(
                    profile: profile,
                    hideRead: $hideRead,
                    searchQuery: $searchQuery,
                    items: items
                )
            }
            .navigationTitle(Text("Inbox", comment: "Navigation title"))
        }
    }
}
