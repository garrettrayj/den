//
//  DeckColumn.swift
//  Den
//
//  Created by Garrett Johnson on 2/4/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeckColumn: View {
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    let isFirst: Bool
    let isLast: Bool
    let items: [Item]
    let pageGeometry: GeometryProxy
    let hideRead: Bool

    var borderedRoundedRectangle: some View {
        RoundedRectangle(cornerRadius: 8).strokeBorder(.separator, lineWidth: 1)
    }

    let minCardHeight: CGFloat = 100

    var body: some View {
        VStack(spacing: 16) {
            FeedNavLink(
                feed: feed,
                leadingPadding: isFirst ? pageGeometry.safeAreaInsets.leading + 32 : 20,
                trailingPadding: isLast ? pageGeometry.safeAreaInsets.trailing + 32 : 20
            )
            .buttonStyle(PinnedHeaderButtonStyle())
            .zIndex(1)
            .ignoresSafeArea()
            .padding(.leading, isFirst ? -pageGeometry.safeAreaInsets.leading - 12 : 0)
            .padding(.trailing, isLast ? -pageGeometry.safeAreaInsets.trailing - 12 : 0)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 8) {
                    if feed.feedData == nil || feed.feedData?.error != nil {
                        FeedUnavailable(feedData: feed.feedData)
                            .frame(minHeight: minCardHeight, alignment: .center)
                            .background(borderedRoundedRectangle)
                    } else if items.isEmpty {
                        FeedEmpty()
                            .frame(minHeight: minCardHeight, alignment: .center)
                            .background(borderedRoundedRectangle)
                    } else if items.unread().isEmpty && hideRead {
                        AllRead()
                            .frame(minHeight: minCardHeight, alignment: .center)
                            .background(borderedRoundedRectangle)
                    } else {
                        ForEach(items.visibilityFiltered(hideRead ? false : nil)) { item in
                            ItemActionView(item: item, feed: feed, profile: profile) {
                                if feed.wrappedPreviewStyle == .expanded {
                                    ExpandedItemPreview(item: item, feed: feed)
                                } else {
                                    CompressedItemPreview(item: item, feed: feed)
                                }
                            }
                            .modifier(RoundedContainerModifier())
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 4)
            .contentMargins(.bottom, pageGeometry.safeAreaInsets.bottom + 16)
            .scrollClipDisabled()
        }
    }
}
