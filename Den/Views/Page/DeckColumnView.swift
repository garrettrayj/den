//
//  DeckColumnView.swift
//  Den
//
//  Created by Garrett Johnson on 2/4/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeckColumnView: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.contentSizeCategory) private var contentSizeCategory

    @ObservedObject var feed: Feed

    let isFirst: Bool
    let isLast: Bool
    let items: [Item]
    let previewStyle: PreviewStyle

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 8, pinnedViews: .sectionHeaders) {
                Section {
                    Group {
                        if feed.feedData == nil || feed.feedData?.error != nil {
                            FeedUnavailableView(feedData: feed.feedData)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(8)
                        } else if items.isEmpty {
                            AllReadStatusView()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(8)
                        } else {
                            ForEach(items) { item in
                                ItemActionView(item: item) {
                                    if previewStyle == .compressed {
                                        ItemCompressedView(item: item)
                                    } else {
                                        ItemExpandedView(item: item)
                                    }
                                }
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(8)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.leading, isFirst ? 12 : 0)
                    .padding(.trailing, isLast ? 12 : 0)
                } header: {
                    header
                }
            }
        }.frame(width: columnWidth)
    }

    private var columnWidth: CGFloat {
        #if targetEnvironment(macCatalyst)
        let typeSize = dynamicTypeSize
        #else
        let typeSize = DynamicTypeSize(contentSizeCategory) ?? dynamicTypeSize
        #endif

        return 300 * typeSize.fontScale
    }

    private var header: some View {
        NavigationLink(value: DetailPanel.feed(feed)) {
            HStack {
                FeedTitleLabelView(title: feed.wrappedTitle, favicon: feed.feedData?.favicon)
                Spacer()
                NavChevronView()
            }
            .padding(.leading, isFirst ? 12 : 0)
            .padding(.trailing, isLast ? 12 : 0)
        }
        .buttonStyle(PinnedHeaderButtonStyle(leadingPadding: 12, trailingPadding: 12))
        .accessibilityIdentifier("deck-feed-button")
    }
}
