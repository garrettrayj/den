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
            VStack(alignment: .leading, spacing: 12) {
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
                        geometry: geometry,
                        list: items.visibilityFiltered(hideRead ? false : nil),
                        lazy: false
                    ) { item in
                        ItemActionView(item: item, feed: feed, profile: profile) {
                            if feed.wrappedPreviewStyle.rawValue == 1 {
                                ItemExpanded(item: item, feed: feed)
                            } else {
                                ItemCompressed(item: item, feed: feed)
                            }
                        }
                        .modifier(RoundedContainerModifier())
                    }
                    .padding()
                    .modifier(SafeAreaModifier(geometry: geometry))
                }
            }
        } header: {
            FeedNavLink(feed: feed, leadingPadding: 16, trailingPadding: 16)
                .buttonStyle(PinnedHeaderButtonStyle())
                .modifier(SafeAreaModifier(geometry: geometry))
        }
    }
}
