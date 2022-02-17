//
//  GadgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetView: View {
    @ObservedObject var viewModel: FeedDisplayViewModel

    var feedData: FeedData? {
        viewModel.feed.feedData
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if feedData != nil && !feedData!.itemsArray.isEmpty {
                ForEach(feedData!.limitedItemsArray) { item in
                    Divider()
                    GadgetItemView(item: item, feed: viewModel.feed)
                        .accessibilityElement(children: .combine)
                }
            } else {
                Divider()
                FeedUnavailableView(feedData: feedData).padding()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .modifier(GroupBlockModifier())
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
                            faviconImage: feedData?.faviconImage
                        )
                        Spacer()
                        if viewModel.refreshing {
                            ProgressView().progressViewStyle(IconProgressStyle())
                        } else {
                            NavChevronView()
                        }
                    }.padding(.horizontal, 12)
                }
                .buttonStyle(FeedTitleButtonStyle())
                .disabled(viewModel.refreshing)
                .accessibilityIdentifier("gadget-feed-button")
            }
        }
    }
}
