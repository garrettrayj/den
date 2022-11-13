//
//  ShowcaseSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseSectionView: View {
    @ObservedObject var feed: Feed
    @Binding var hideRead: Bool

    let width: CGFloat

    var body: some View {
        Section {
            if feed.hasContent {
                if visibleItems.isEmpty {
                    AllReadCompactView().padding(.horizontal, 8)
                } else {
                    BoardView(
                        width: width,
                        list: visibleItems,
                        content: { item in
                            ItemActionView(item: item) {
                                ItemPreviewView(item: item)
                            }
                            .cornerRadius(8)
                        }
                    ).padding()
                }
            } else {
                FeedUnavailableView(feedData: feed.feedData)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
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
                .padding(.horizontal, 20)
            }
            .buttonStyle(
                FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
            )
            .accessibilityIdentifier("showcase-section-feed-button")
        }
    }

    private var visibleItems: [Item] {
        feed.feedData?.previewItems.filter { item in
            hideRead ? item.read == false : true
        } ?? []
    }
}
