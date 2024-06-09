//
//  FeedItemGroup.swift
//  Den
//
//  Created by Garrett Johnson on 9/28/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedItemGroup: View {
    @Bindable var feed: Feed

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
        Section {
            if feed.feedData == nil || feed.feedData?.error != nil {
                FeedUnavailable(feed: feed)
            } else if items.isEmpty {
                FeedEmpty()
            } else if items.unread.isEmpty && hideRead {
                AllRead()
            } else {
                ForEach(filteredItems) { item in
                    ItemActionView(item: item, isLastInList: item == filteredItems.last) {
                        if feed.wrappedPreviewStyle == .expanded {
                            ItemPreviewExpanded(item: item, feed: feed)
                        } else {
                            ItemPreviewCompressed(item: item, feed: feed)
                        }
                    }
                }
            }
        } header: {
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
        } footer: {
            Spacer().frame(height: 8)
        }
    }
}
