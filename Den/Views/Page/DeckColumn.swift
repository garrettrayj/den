//
//  DeckColumn.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeckColumn: View {
    @Bindable var feed: Feed
    
    let items: [Item]
    
    @AppStorage("HideRead") private var hideRead: Bool = false

    private var filteredItems: [Item] {
        items.visibilityFiltered(hideRead ? false : nil)
    }

    var body: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                if feed.feedData == nil || feed.feedData?.error != nil {
                    FeedUnavailable(feed: feed)
                } else if items.isEmpty {
                    FeedEmpty()
                } else if items.unread.isEmpty && hideRead {
                    AllRead()
                } else {
                    ForEach(filteredItems) { item in
                        ItemActionView(item: item, isLastInList: filteredItems.last == item) {
                            if feed.wrappedPreviewStyle.rawValue == 1 {
                                ItemPreviewExpanded(item: item, feed: feed)
                            } else {
                                ItemPreviewCompressed(item: item, feed: feed)
                            }
                        }
                    }
                }
            } header: {
                FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
            }
        }
    }
}
