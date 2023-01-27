//
//  FeedItemPreviewView.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedItemPreviewView: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var item: Item

    var body: some View {
        if let feed = item.feedData?.feed {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink(value: DetailPanel.feed(feed)) {
                    HStack {
                        FeedTitleLabelView(
                            title: item.feedData?.feed?.wrappedTitle ?? "Untitled",
                            favicon: item.feedData?.favicon
                        )
                        Spacer()
                        NavChevronView()
                    }
                }
                .buttonStyle(FeedTitleButtonStyle())
                .accessibilityIdentifier("item-feed-button")

                Divider()

                ItemActionView(item: item) {
                    ItemPreviewView(item: item)
                }
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(8)
        }
    }
}
