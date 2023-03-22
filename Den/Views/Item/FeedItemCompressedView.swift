//
//  FeedItemCompressedView.swift
//  Den
//
//  Created by Garrett Johnson on 2/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedItemCompressedView: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var item: Item

    var body: some View {
        if let feed = item.feedData?.feed {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink(value: DetailPanel.feed(feed)) {
                    HStack {
                        FeedTitleLabel(
                            title: item.feedData?.feed?.wrappedTitle ?? "Untitled",
                            favicon: item.feedData?.favicon,
                            read: item.read
                        )
                        Spacer()
                        ButtonChevron()
                    }
                }
                .buttonStyle(FeedTitleButtonStyle())
                .accessibilityIdentifier("item-feed-button")

                Divider()

                ItemActionView(item: item) {
                    ItemCompressedView(item: item)
                }
            }
            .modifier(RaisedGroupModifier())
        }
    }
}
