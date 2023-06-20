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

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 12) {
                if feed.feedData == nil || feed.feedData?.error != nil {
                    FeedUnavailable(feedData: feed.feedData)
                        .padding(12)
                        .background(QuaternaryGroupedBackground())
                        .modifier(RoundedContainerModifier())
                }

                if items.isEmpty && feed.feedData != nil && feed.feedData?.error == nil {
                    AllRead()
                        .padding(12)
                        .background(QuaternaryGroupedBackground())
                        .modifier(RoundedContainerModifier())
                } else if !items.isEmpty {
                    ForEach(items) { item in
                        ItemActionView(item: item, feed: feed, profile: profile) {
                            if feed.wrappedPreviewStyle == .expanded {
                                ItemExpanded(item: item, feed: feed)
                            } else {
                                ItemCompressed(item: item, feed: feed)
                            }
                        }
                        .background(SecondaryGroupedBackground())
                        .modifier(RoundedContainerModifier())
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.leading, 8)
            .padding(.trailing, 4)
            .padding(.leading, isFirst ? 8 : 0)
            .padding(.trailing, isLast ? 12 : 0)
        }
        .safeAreaInset(edge: .top) {
            header.padding(.top, pageGeometry.safeAreaInsets.top)
        }
        .safeAreaInset(edge: .bottom) {
            EmptyView().frame(height: pageGeometry.safeAreaInsets.bottom)
        }
        .frame(width: columnWidth)
    }

    private var columnWidth: CGFloat {
        return 300 * dynamicTypeSize.layoutScalingFactor
    }

    private var header: some View {
        FeedNavLink(
            feed: feed,
            leadingPadding: isFirst ? 8 : 0,
            trailingPadding: isLast ? 12 : 0
        )
        .buttonStyle(PinnedHeaderButtonStyle(leadingPadding: 8, trailingPadding: 16))
    }
}
