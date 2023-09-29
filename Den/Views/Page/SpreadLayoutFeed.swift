//
//  SpreadLayoutFeed.swift
//  Den
//
//  Created by Garrett Johnson on 9/28/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SpreadLayoutFeed: View {
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    let hideRead: Bool
    let items: [Item]
    let filteredItems: [Item]

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
                }
            }
        } header: {
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
        } footer: {
            Spacer()
        }
    }
}
