//
//  DeckColumn.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct DeckColumn: View {
    @ObservedObject var feed: Feed

    let hideRead: Bool
    let items: [Item]
    let filteredItems: [Item]

    init(feed: Feed, hideRead: Bool, items: [Item]) {
        self.feed = feed
        self.hideRead = hideRead
        self.items = items
        self.filteredItems = items.visibilityFiltered(hideRead ? false : nil)
    }

    var body: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                if feed.feedData == nil || feed.feedData?.error != nil {
                    FeedUnavailable(feedData: feed.feedData)
                } else if items.isEmpty {
                    FeedEmpty()
                } else if items.unread().isEmpty && hideRead {
                    AllRead()
                } else {
                    ForEach(filteredItems) { item in
                        ItemActionView(item: item, roundedBottom: filteredItems.last == item) {
                            if feed.wrappedPreviewStyle.rawValue == 1 {
                                ItemPreviewExpanded(item: item, feed: feed)
                            } else {
                                ItemPreviewCompressed(item: item, feed: feed)
                            }
                        }
                        if item != filteredItems.last {
                            BackedDivider()
                        }
                    }
                }
            } header: {
                FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
            }
        }
    }
}
