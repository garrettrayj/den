//
//  ShowcaseSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseSectionView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @ObservedObject var feed: Feed
    var width: CGFloat

    var body: some View {
        Section(header: header.modifier(PinnedSectionHeaderModifier())) {
            if feed.feedData != nil && feed.feedData!.itemsArray.count > 0 {
                BoardView(
                    width: width,
                    list: feed.feedData?.limitedItemsArray ?? [],
                    content: { item in
                        ItemPreviewView(item: item).modifier(GroupBlockModifier())
                    }
                ).padding()
            } else {
                FeedUnavailableView(feedData: feed.feedData)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .padding()

            }
        }
    }

    private var header: some View {
        HStack {
            if feed.id != nil {
                NavigationLink {
                    FeedView(viewModel: FeedViewModel(
                        feed: feed,
                        refreshing: false
                    ))
                } label: {
                    HStack {
                        FeedTitleLabelView(
                            title: feed.wrappedTitle,
                            faviconImage: feed.feedData?.faviconImage
                        )
                        NavChevronView()
                        Spacer()
                    }
                    .padding(.leading, 28)
                    .padding(.trailing, 8)
                }
                .buttonStyle(
                    FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
                )
                .accessibilityIdentifier("showcase-section-feed-button")
            }
            Spacer()
            Group {
                if UIDevice.current.userInterfaceIdiom != .phone {
                    FeedRefreshedLabelView(refreshed: feed.refreshed)
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 28)
        }
    }
}
