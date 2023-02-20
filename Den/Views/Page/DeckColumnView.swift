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

    @Binding var hideRead: Bool

    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 8, pinnedViews: .sectionHeaders) {
                Section {
                    Group {
                        if feed.hasContent {
                            if hideRead == true && feed.feedData!.previewItems.unread().isEmpty {
                                AllReadStatusView(hiddenCount: feed.feedData!.previewItems.read().count)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                            } else {
                                ForEach(feed.visibleItems(hideRead)) { item in
                                    ItemActionView(item: item) {
                                        ItemPreviewView(item: item)
                                    }
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                                }
                                Spacer()
                            }
                        } else {
                            FeedUnavailableView(feedData: feed.feedData)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.leading, 8)
                    .padding(.leading, isFirst ? 8 : 0)
                    .padding(.trailing, isLast ? 16 : 0)
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
                NavChevronView().padding(.trailing, 8)
            }
            .padding(.leading, isFirst ? 12 : 0)
            .padding(.trailing, isLast ? 12 : 0)
        }
        .buttonStyle(PinnedHeaderButtonStyle(leadingPadding: 8 , trailingPadding: 4))
        .accessibilityIdentifier("deck-feed-button")
    }

    private var allRead: Bool {
        guard
            let feedData = feed.feedData,
            !feedData.previewItems.isEmpty
        else { return false }

        return feedData.previewItems.unread().isEmpty
    }
}
