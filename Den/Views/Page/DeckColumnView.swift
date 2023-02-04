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

    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 8) {
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
                        FeedUnavailableView(feedData: feed.feedData).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .frame(minWidth: 272, idealWidth: 300, maxWidth: 360)
    }

    private var header: some View {
        HStack {
            NavigationLink(value: DetailPanel.feed(feed)) {
                HStack {
                    FeedTitleLabelView(
                        title: feed.wrappedTitle,
                        favicon: feed.feedData?.favicon
                    )
                    Spacer()
                    NavChevronView()
                }
            }
            .buttonStyle(PinnedHeaderButtonStyle(horizontalPadding: 8))
            .accessibilityIdentifier("gadget-feed-button")
        }
    }

    private var allRead: Bool {
        guard
            let feedData = feed.feedData,
            !feedData.previewItems.isEmpty
        else { return false }

        return feedData.previewItems.unread().isEmpty
    }
}
