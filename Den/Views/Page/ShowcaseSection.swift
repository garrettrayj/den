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

    var body: some View {
        Section {
            if feed.feedData == nil || feed.feedData?.error != nil {
                FeedUnavailable(feedData: feed.feedData)
                    .padding(12)
                    .background(QuaternaryGroupedBackground())
                    .modifier(RoundedContainerModifier())
                    .padding()
                    .modifier(SafeAreaModifier(geometry: geometry))
            } else if items.isEmpty {
                AllRead()
                    .padding(12)
                    .background(QuaternaryGroupedBackground())
                    .modifier(RoundedContainerModifier())
                    .padding()
                    .modifier(SafeAreaModifier(geometry: geometry))
            } else {
                BoardView(geometry: geometry, list: items, lazy: false) { item in
                    ItemActionView(item: item, feed: feed, profile: profile) {
                        if feed.wrappedPreviewStyle.rawValue == 1 {
                            ItemExpanded(item: item, feed: feed)
                        } else {
                            ItemCompressed(item: item, feed: feed)
                        }
                    }
                    .background(SecondaryGroupedBackground())
                    .modifier(RoundedContainerModifier())
                }
                .padding(.vertical)
                .modifier(SafeAreaModifier(geometry: geometry))
            }
        } header: {
            NavigationLink(value: SubDetailPanel.feed(feed)) {
                HStack {
                    FeedTitleLabel(
                        title: feed.wrappedTitle,
                        favicon: feed.feedData?.favicon
                    )
                    Spacer()
                    ButtonChevron()
                }
                .modifier(SafeAreaModifier(geometry: geometry))
            }
            .buttonStyle(PinnedHeaderButtonStyle())
            .accessibilityIdentifier("showcase-section-feed-button")
        }
    }
}
