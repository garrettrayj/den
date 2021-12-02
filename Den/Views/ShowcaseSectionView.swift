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
            BoardView(
                list: viewModel.feed.feedData?.previewItemsArray ?? [],
                content: { item in
                    ShowcaseItemView(item: item)
                }
            ).padding()
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
                .buttonStyle(GadgetHeaderButtonStyle())
            }
            Spacer()
            if viewModel.refreshing {
                ProgressView().progressViewStyle(IconProgressStyle())
            }
        }
    }
}
