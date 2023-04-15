//
//  FeedItemExpanded.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedItemExpanded: View {
    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var showExtraTag: Bool = false

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
                        if showExtraTag && item.extra {
                            Text("Extra").font(.caption).foregroundColor(.secondary)
                        }
                        ButtonChevron()
                    }
                }
                .buttonStyle(FeedTitleButtonStyle())
                .accessibilityIdentifier("item-feed-button")

                Divider()

                ItemActionView(item: item, profile: profile) {
                    ItemExpanded(item: item)
                }
            }
            .modifier(RaisedGroupModifier())
        }
    }
}
