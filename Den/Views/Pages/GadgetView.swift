//
//  GadgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @ObservedObject var viewModel: FeedViewModel

    var feedData: FeedData? {
        viewModel.feed.feedData
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if feedData != nil && !feedData!.itemsArray.isEmpty {
                items
            } else {
                Divider()
                FeedUnavailableView(feedData: feedData).padding()
            }
        }
        .modifier(GroupBlockModifier())
    }

    private var header: some View {
        HStack {
            if viewModel.feed.id != nil {
                NavigationLink {
                    FeedView(viewModel: viewModel)
                } label: {
                    FeedTitleLabelView(
                        title: viewModel.feed.wrappedTitle,
                        faviconImage: feedData?.faviconImage
                    ).padding(.horizontal, 12)
                }
                .buttonStyle(FeedTitleButtonStyle())
                .disabled(refreshManager.isRefreshing)
                .accessibilityIdentifier("gadget-feed-button")
            }

            if viewModel.refreshing {
                Spacer()
                ProgressView().progressViewStyle(IconProgressStyle()).padding(.trailing, 12)
            }
        }.frame(height: 32, alignment: .leading)
    }

    private var items: some View {
        ForEach(feedData!.limitedItemsArray) { item in
            Divider()
            GadgetItemView(
                item: item,
                feed: viewModel.feed
            )
        }
    }
}
