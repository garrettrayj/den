//
//  ShowcaseSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseSectionView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        Section(header: header.modifier(PinnedSectionHeaderModifier())) {
            if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                BoardView(
                    list: viewModel.feed.feedData?.limitedItemsArray ?? [],
                    content: { item in
                        ItemPreviewView(item: item).modifier(GroupBlockModifier())
                    }
                ).padding()
            } else {
                FeedUnavailableView(feedData: viewModel.feed.feedData)
                    .padding(.vertical)
                    .padding(.horizontal, 28)
            }
        }
    }

    private var header: some View {
        HStack {
            if viewModel.feed.id != nil {
                NavigationLink {
                    FeedView(viewModel: viewModel)
                } label: {
                    FeedTitleLabelView(
                        title: viewModel.feed.wrappedTitle,
                        faviconImage: viewModel.feed.feedData?.faviconImage
                    )
                    .padding(.leading, 28)
                    .padding(.trailing, 8)
                }
                .buttonStyle(
                    FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
                )
                .disabled(refreshManager.isRefreshing)
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
