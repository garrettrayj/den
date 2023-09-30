//
//  SpreadGroup.swift
//  Den
//
//  Created by Garrett Johnson on 9/28/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SpreadGroup: View {
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    let hideRead: Bool
    let items: [Item]
    let filteredItems: [Item]

    init(feed: Feed, profile: Profile, hideRead: Bool, items: [Item]) {
        self.feed = feed
        self.profile = profile
        self.hideRead = hideRead
        self.items = items
        self.filteredItems = items.visibilityFiltered(hideRead ? false : nil)
    }

    var body: some View {
        Section {
            if feed.feedData == nil || feed.feedData?.error != nil {
                FeedUnavailable(feedData: feed.feedData)
            } else if items.isEmpty {
                FeedEmpty()
            } else if items.unread().isEmpty && hideRead {
                AllRead()
            } else {
                ForEach(filteredItems) { item in
                    ItemActionView(
                        item: item,
                        feed: feed,
                        profile: profile,
                        roundedBottom: item == filteredItems.last
                    ) {
                        if feed.wrappedPreviewStyle == .expanded {
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
        } footer: {
            Spacer(minLength: 8)
        }
    }
}
