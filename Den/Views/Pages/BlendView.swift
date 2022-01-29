//
//  BlendView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        if viewModel.page.limitedItemsArray.isEmpty {
            StatusBoxView(message: Text("No Items"), symbol: "questionmark.square.dashed")
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
        BoardView(list: viewModel.page.limitedItemsArray) { item in
            if item.feedData?.feed != nil {
                BlendItemView(
                    item: item,
                    feedViewModel: viewModel.feedViewModels.first(where: { feedViewModel in
                        feedViewModel.feed == item.feedData?.feed
                    })
                )
            }
        }
        .padding([.horizontal, .bottom])
        #if targetEnvironment(macCatalyst)
        .padding(.top, 8)
        #endif
    }
}
