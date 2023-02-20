//
//  ShowcaseSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ShowcaseSectionView: View {
    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool

    let width: CGFloat

    var body: some View {
        Section {
            if feed.hasContent {
                if feed.visibleItems(hideRead).isEmpty {
                    AllReadStatusView(hiddenCount: feed.feedData!.itemsArray.read().count)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(8)
                        .padding()
                } else {
                    BoardView(
                        width: width,
                        list: feed.visibleItems(hideRead),
                        content: { item in
                            ItemActionView(item: item) {
                                ItemPreviewView(item: item)
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                        }
                    ).modifier(SectionBoardModifier())
                }
            } else {
                FeedUnavailableView(feedData: feed.feedData)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .padding()

            }
        } header: {
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
            .buttonStyle(PinnedHeaderButtonStyle())
            .accessibilityIdentifier("showcase-section-feed-button")
        }
    }
}
