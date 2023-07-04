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

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 8) {
                if feed.feedData == nil || feed.feedData?.error != nil {
                    FeedUnavailable(feedData: feed.feedData)
                        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(.quaternary, lineWidth: 1.5))
                        
                } else if items.isEmpty {
                    FeedEmpty()
                        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(.quaternary, lineWidth: 1.5))
                } else if items.unread().isEmpty && hideRead {
                    AllRead()
                        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(.quaternary, lineWidth: 1.5))
                } else {
                    ForEach(items.visibilityFiltered(hideRead ? false : nil)) { item in
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
            .padding(.leading, 4)
            .padding(.trailing, 4)
            .padding(.leading, isFirst ? 12 : 0)
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
            leadingPadding: isFirst ? 12 : 0,
            trailingPadding: isLast ? 12 : 0
        )
        .buttonStyle(PinnedHeaderButtonStyle(leadingPadding: 16, trailingPadding: 16))
    }
}
