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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
                leadingPadding: 20,
                trailingPadding: 20
            )
            .buttonStyle(PinnedHeaderButtonStyle())
            .padding(.top, pageGeometry.safeAreaInsets.top)
            .zIndex(1)

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
                                    ItemExpanded(item: item, feed: feed)
                                } else {
                                    ItemCompressed(item: item, feed: feed)
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

    private var columnWidth: CGFloat {
        return 300 * dynamicTypeSize.layoutScalingFactor
    }
}
