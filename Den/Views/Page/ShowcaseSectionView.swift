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
                if feed.visibleItems(hideRead).isEmpty {
                    AllReadCompactView().padding(.horizontal, 8)
                } else {
                    BoardView(
                        width: width,
                        list: feed.visibleItems(hideRead),
                        content: { item in
                            ItemActionView(item: item) {
                                ItemPreviewView(item: item)
                            }
                            .cornerRadius(8)
                        }
                    )
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
                        favicon: feed.feedData?.favicon,
                        dimmed: allRead
                    )
                    Spacer()
                    NavChevronView()
                }
                .padding(.horizontal)
            }
            .buttonStyle(
                FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
            )
            .accessibilityIdentifier("showcase-section-feed-button")
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
