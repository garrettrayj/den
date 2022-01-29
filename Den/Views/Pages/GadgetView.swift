//
//  GadgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                items
            } else {
                Divider()
                FeedUnavailableView(feedData: viewModel.feed.feedData)
                    .padding()
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
                        faviconImage: viewModel.feed.feedData?.faviconImage
                    )
                }
                .buttonStyle(FeedTitleButtonStyle())
                .disabled(refreshManager.isRefreshing)
            }
            Spacer()
            if viewModel.refreshing {
                ProgressView().progressViewStyle(IconProgressStyle())
            }
        }
        .frame(height: 32, alignment: .leading)
        .padding(.horizontal, 12)
    }

    private var items: some View {
        ForEach(viewModel.feed.feedData!.limitedItemsArray) { item in
            Divider()
            GadgetItemView(
                item: item,
                feed: viewModel.feed
            )
        }
    }
}
