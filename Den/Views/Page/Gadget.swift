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

    var visibilityFilteredItems: [Item] {
        items.visibilityFiltered(hideRead ? false : nil)
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
                    ForEach(visibilityFilteredItems) { item in
                        ItemActionView(item: item, feed: feed, profile: profile) {
                            if feed.wrappedPreviewStyle.rawValue == 1 {
                                ItemPreviewExpanded(item: item, feed: feed)
                            } else {
                                ItemPreviewCompressed(item: item, feed: feed)
                            }
                        }
                        if item != visibilityFilteredItems.last {
                            Divider()
                        }
                    }
                }
            } header: {
                VStack(spacing: 0) {
                    FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
                        .background {
                            RoundedRectangle(cornerRadius: 8).fill(.background.quinary)
                        }
                    Divider()
                }
            }
        }
        .modifier(RoundedContainerModifier())
    }
}
