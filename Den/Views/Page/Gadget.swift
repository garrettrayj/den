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

    let items: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationLink(value: DetailPanel.feed(feed)) {
                HStack {
                    FeedTitleLabel(
                        title: feed.wrappedTitle,
                        favicon: feed.feedData?.favicon
                    )
                    Spacer()
                    ButtonChevron()
                }
            }
            .buttonStyle(FeedTitleButtonStyle())
            .accessibilityIdentifier("gadget-feed-button")

            if feed.feedData == nil || feed.feedData?.error != nil {
                Divider()
                FeedUnavailable(feedData: feed.feedData).frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(SecondaryGroupedBackground())
            } else if items.isEmpty {
                Divider()
                AllRead()
                    .padding(12)
                    .background(SecondaryGroupedBackground())
            } else {
                ForEach(items) { item in
                    Divider()
                    ItemActionView(item: item, profile: profile) {
                        ItemCompressed(item: item)
                    }
                    .accessibilityIdentifier("gadget-item-button")
                }
            }
        }
        .modifier(RoundedContainerModifier())
    }
}
