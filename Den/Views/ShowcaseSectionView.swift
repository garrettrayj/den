//
//  ShowcaseSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseSectionView: View {
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        Section(header: header.modifier(PinnedSectionHeaderModifier())) {
            if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                BoardView(
                    list: viewModel.feed.feedData?.previewItemsArray ?? [],
                    content: { item in
                        ShowcaseItemView(item: item)
                    }
                ).padding()
            } else {
                FeedUnavailableView(feed: viewModel.feed)
                    .padding(.vertical)
                    .padding(.horizontal, 20)
            }
        }
    }

    private var header: some View {
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
}
