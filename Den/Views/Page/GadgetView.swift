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

    let items: [Item]
    let previewStyle: PreviewStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if feed.feedData == nil || feed.feedData?.error != nil {
                Divider()
                FeedUnavailableView(feedData: feed.feedData).frame(maxWidth: .infinity, alignment: .leading)
            } else if items.isEmpty {
                Divider()
                AllReadStatusView()
            } else {
                ForEach(items) { item in
                    Divider()
                    ItemActionView(item: item) {
                        if previewStyle == .compressed {
                            ItemCompressedView(item: item)
                        } else {
                            ItemExpandedView(item: item)
                        }
                    }
                    .accessibilityIdentifier("gadget-item-button")
                }
            }
        }
        .modifier(RaisedGroupModifier())
    }

    private var header: some View {
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
