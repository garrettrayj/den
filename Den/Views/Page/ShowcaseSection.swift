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
                    .padding()
                    .modifier(SafeAreaModifier(geometry: geometry))
            } else if items.isEmpty {
                AllRead()
                    .modifier(RoundedContainerModifier())
                    .padding()
                    .modifier(SafeAreaModifier(geometry: geometry))
            } else {
                BoardView(
                    geometry: geometry,
                    list: items,
                    isLazy: false,
                    content: { item in
                        ItemActionView(item: item, profile: profile) {
                            if feed.wrappedPreviewStyle == .expanded {
                                ItemExpanded(item: item)
                            } else {
                                ItemCompressed(item: item)
                            }
                        }
                        .modifier(RoundedContainerModifier())
                    }
                )
                .padding(.vertical)
                .modifier(SafeAreaModifier(geometry: geometry))
            }
        } header: {
            NavigationLink(value: DetailPanel.feed(feed)) {
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
