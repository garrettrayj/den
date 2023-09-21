//
//  ShowcaseSection.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ShowcaseSection: View {
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    let items: [Item]
    let geometry: GeometryProxy
    let hideRead: Bool

    var body: some View {
        Section {
            HStack {
                Spacer()
                if feed.feedData == nil || feed.feedData?.error != nil {
                    FeedUnavailable(feedData: feed.feedData)
                        .modifier(SafeAreaModifier(geometry: geometry))
                } else if items.isEmpty {
                    FeedEmpty()
                        .modifier(SafeAreaModifier(geometry: geometry))
                } else if items.unread().isEmpty && hideRead {
                    AllRead()
                        .modifier(SafeAreaModifier(geometry: geometry))
                } else if !items.isEmpty {
                    BoardView(
                        width: geometry.size.width,
                        list: items.visibilityFiltered(hideRead ? false : nil)
                    ) { item in
                        ItemActionView(item: item, feed: feed, profile: profile) {
                            if feed.wrappedPreviewStyle.rawValue == 1 {
                                ItemPreviewExpanded(item: item, feed: feed)
                            } else {
                                ItemPreviewCompressed(item: item, feed: feed)
                            }
                        }
                        .modifier(RoundedContainerModifier())
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 8)
                    .modifier(SafeAreaModifier(geometry: geometry))
                }
                Spacer()
            }
        } header: {
            FeedNavLink(feed: feed, leadingPadding: 32, trailingPadding: 32)
                .buttonStyle(PinnedHeaderButtonStyle())
                .modifier(SafeAreaModifier(geometry: geometry))
        }
    }
}
