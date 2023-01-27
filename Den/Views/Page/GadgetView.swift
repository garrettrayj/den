//
//  GadgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GadgetView: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            VStack(spacing: 0) {
                if feed.hasContent {
                    ForEach(feed.visibleItems(hideRead)) { item in
                        GadgetItemView(item: item)
                    }

                    if hideRead == true && feed.feedData!.previewItems.unread().isEmpty {
                        Divider()
                        AllReadCompactView()
                    }
                } else {
                    Divider()
                    FeedUnavailableView(feedData: feed.feedData)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            .clipped()
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
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
            .buttonStyle(FeedTitleButtonStyle())
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
