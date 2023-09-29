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

struct Gadget: View {
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    let hideRead: Bool
    let items: [Item]
    let filteredItems: [Item]

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
                        ItemActionView(
                            item: item,
                            feed: feed,
                            profile: profile,
                            roundedBottom: filteredItems.last == item
                        ) {
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
