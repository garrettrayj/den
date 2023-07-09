//
//  Gadget.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

/// Feed display for the grouped page layout.
struct Gadget: View {
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    let items: [Item]
    let hideRead: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())

            if feed.feedData == nil || feed.feedData?.error != nil {
                Divider()
                FeedUnavailable(feedData: feed.feedData)
            } else if items.isEmpty {
                Divider()
                FeedEmpty()
            } else if items.unread().isEmpty && hideRead {
                Divider()
                AllRead()
            } else {
                VStack(spacing: 0) {
                    ForEach(items.visibilityFiltered(hideRead ? false : nil)) { item in
                        Divider()
                        ItemActionView(item: item, feed: feed, profile: profile) {
                            ItemCompressed(item: item, feed: feed)
                        }
                        .accessibilityIdentifier("gadget-item-button")
                    }
                }
            }
        }
        .modifier(RoundedContainerModifier())
    }
}
