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
                        ItemPreviewView(item: item)
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
                }
                .buttonStyle(FeedTitleButtonStyle())
                .disabled(refreshManager.isRefreshing)
            }
            Spacer()
            if viewModel.refreshing {
                ProgressView().progressViewStyle(IconProgressStyle())
            } else if UIDevice.current.userInterfaceIdiom != .phone {
                FeedRefreshedLabelView(refreshed: viewModel.feed.refreshed)
            }
        }
    }
}
