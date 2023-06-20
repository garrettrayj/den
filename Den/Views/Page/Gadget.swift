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
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())

            if feed.feedData == nil || feed.feedData?.error != nil {
                Divider()
                FeedUnavailable(feedData: feed.feedData)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }

            if items.isEmpty && feed.feedData != nil && feed.feedData?.error == nil {
                Divider()
                AllRead().padding(12)
            } else if !items.isEmpty {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        Divider()
                        ItemActionView(item: item, feed: feed, profile: profile) {
                            ItemCompressed(item: item, feed: feed)
                        }
                        .accessibilityIdentifier("gadget-item-button")
                    }
                }
            }
        }
        .background(SecondaryGroupedBackground())
        .modifier(RoundedContainerModifier())
    }
}
