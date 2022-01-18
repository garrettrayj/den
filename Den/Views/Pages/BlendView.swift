//
//  BlendView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendView: View {
    #if !targetEnvironment(macCatalyst)
    @EnvironmentObject var refreshManager: RefreshManager
    #endif

    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        if viewModel.page.previewItemsArray.isEmpty {
            StatusBoxView(message: "No Items", symbol: "questionmark.square.dashed")
        } else {
            #if targetEnvironment(macCatalyst)
            ScrollView(.vertical) {
                blendDisplay
            }
            #else
            RefreshableScrollView(
                onRefresh: { done in
                    refreshManager.refresh(page: viewModel.page)
                    done()
                },
                content: { blendDisplay }
            )
            #endif
        }
    }

    var blendDisplay: some View {
        BoardView(list: viewModel.page.previewItemsArray) { item in
            if item.feedData?.feed != nil {
                ItemPreviewView(
                    item: item,
                    feedViewModel: FeedViewModel(feed: item.feedData!.feed!, refreshing: viewModel.refreshing)
                ).disabled(viewModel.refreshing)
            }
        }
        .padding([.horizontal, .bottom])
        .padding(.top, 8)
    }
}
