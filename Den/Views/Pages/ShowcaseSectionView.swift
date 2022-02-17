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
    @ObservedObject var viewModel: FeedDisplayViewModel
    var width: CGFloat

    var body: some View {
        Section(header: header.modifier(PinnedSectionHeaderModifier())) {
            if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                BoardView(
                    width: width,
                    list: viewModel.feed.feedData?.limitedItemsArray ?? [],
                    content: { item in
                        ItemPreviewView(item: item).modifier(GroupBlockModifier())
                    }
                ).padding()
            } else {
                FeedUnavailableView(feedData: viewModel.feed.feedData)
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
            if viewModel.feed.id != nil {
                NavigationLink {
                    FeedView(viewModel: FeedViewModel(
                        feed: viewModel.feed,
                        refreshing: viewModel.refreshing
                    ))
                } label: {
                    HStack {
                        FeedTitleLabelView(
                            title: viewModel.feed.wrappedTitle,
                            faviconImage: viewModel.feed.feedData?.faviconImage
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
                .disabled(viewModel.refreshing)
                .accessibilityIdentifier("showcase-section-feed-button")
            }
            Spacer()
            Group {
                if viewModel.refreshing {
                    ProgressView().progressViewStyle(IconProgressStyle())
                } else if UIDevice.current.userInterfaceIdiom != .phone {
                    FeedRefreshedLabelView(refreshed: viewModel.feed.refreshed)
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 28)
        }
    }
}
