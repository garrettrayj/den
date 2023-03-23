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

    let isFirst: Bool
    let isLast: Bool
    let items: [Item]
    let previewStyle: PreviewStyle
    let pageGeometry: GeometryProxy

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 8) {
                    if feed.feedData == nil || feed.feedData?.error != nil {
                        FeedUnavailable(feedData: feed.feedData)
                    } else if items.isEmpty {
                        AllRead()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .modifier(RaisedGroupModifier())
                    } else {
                        ForEach(items) { item in
                            ItemActionView(item: item) {
                                if previewStyle == .compressed {
                                    ItemCompressed(item: item)
                                } else {
                                    ItemExpanded(item: item)
                                }
                            }
                            .modifier(RaisedGroupModifier())
                        }
                    }
                    Spacer(minLength: 16)
                }
                .padding(.top, 8)
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
        }
        .frame(width: columnWidth)
    }

    private var columnWidth: CGFloat {
        return 300 * dynamicTypeSize.layoutScalingFactor
    }

    private var header: some View {
        NavigationLink(value: DetailPanel.feed(feed)) {
            HStack {
                FeedTitleLabel(title: feed.wrappedTitle, favicon: feed.feedData?.favicon)
                Spacer()
                ButtonChevron()
            }
            .padding(.leading, isFirst ? 16 : 0)
            .padding(.trailing, isLast ? 8 : 0)
        }
        .buttonStyle(PinnedHeaderButtonStyle(leadingPadding: 12, trailingPadding: 16))
        .accessibilityIdentifier("deck-feed-button")
    }
}
