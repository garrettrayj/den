//
//  FeedItemExpanded.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedItemExpanded: View {
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var showExtraTag: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationLink(value: DetailPanel.feed(feed)) {
                HStack {
                    FeedTitleLabel(
                        title: feed.wrappedTitle,
                        favicon: item.feedData?.favicon
                    )
                    Spacer()
                    if showExtraTag && item.extra {
                        Text("Extra").font(.caption).foregroundColor(.secondary)
                    }
                    ButtonChevron()
                }
            }
            .buttonStyle(FeedTitleButtonStyle())
            .accessibilityIdentifier("item-feed-button")

            Divider()

            ItemActionView(item: item, feed: feed, profile: profile) {
                ItemExpanded(item: item, feed: feed)
            }
        }
        .background(SecondaryGroupedBackground())
        .modifier(RoundedContainerModifier())
    }
}
