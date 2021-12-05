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
        widgetContent
            .padding(.top, 8)
            .padding([.horizontal, .bottom], 12)
            .modifier(GroupBlockModifier())
    }

    private var widgetContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            feedHeader
            if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                feedItems
            } else {
                Divider()
                FeedUnavailableView(feed: viewModel.feed).padding()
            }
        }
    }

    private var feedHeader: some View {
        HStack {
            if viewModel.feed.id != nil {
                NavigationLink {
                    FeedView(viewModel: viewModel)
                } label: {
                    FeedTitleLabelView(feed: viewModel.feed)
                }
                .buttonStyle(FeedTitleButtonStyle())
            }
            Spacer()
            if viewModel.refreshing {
                ProgressView().progressViewStyle(IconProgressStyle())
            }
        }
    }

    private var feedItems: some View {
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
