//
//  GadgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetView: View {
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(alignment: .leading, spacing: 8) {
                if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                    items
                } else {
                    Divider()
                    FeedUnavailableView(feedData: viewModel.feed.feedData).padding(.vertical, 4).padding(.horizontal, 8)
                }
            }
        }
        .padding([.horizontal, .bottom], 12)
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
                .disabled(viewModel.refreshing)
            }
            Spacer()
            if viewModel.refreshing {
                ProgressView().progressViewStyle(IconProgressStyle())
            }
        }.frame(height: 32)
    }

    private var items: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.feed.feedData!.itemsArray.prefix(viewModel.feed.wrappedPreviewLimit)) { item in
                Group {
                    Divider()
                    GadgetItemView(
                        item: item,
                        feed: viewModel.feed
                    )
                }
            }
        }
    }
}
