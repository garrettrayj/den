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

    let items: [Item]
    let previewStyle: PreviewStyle
    let width: CGFloat

    var body: some View {
        Section {
            if feed.feedData == nil || feed.feedData?.error != nil {
                FeedUnavailableView(feedData: feed.feedData)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background)
                    .cornerRadius(8)
                    .modifier(SectionContentPaddingModifier())
            } else if items.isEmpty {
                AllReadStatusView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background)
                    .cornerRadius(8)
                    .modifier(SectionContentPaddingModifier())
            } else {
                BoardView(
                    width: width,
                    list: items,
                    content: { item in
                        ItemActionView(item: item) {
                            if previewStyle == .compressed {
                                ItemCompressedView(item: item)
                            } else {
                                ItemExpandedView(item: item)
                            }
                        }
                        .modifier(RaisedGroupModifier())
                    }
                ).modifier(SectionContentPaddingModifier())
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
