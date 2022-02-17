//
//  GadgetsView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetsView: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var viewModel: PageViewModel

    var frameSize: CGSize

    var body: some View {
        #if targetEnvironment(macCatalyst)
        ScrollView(.vertical) { content }
        #else
        RefreshableScrollView(
            onRefresh: { done in
                refreshManager.refresh(page: viewModel.page)
                done()
            },
            content: { content }
        )
        #endif
    }

    var content: some View {
        BoardView(width: frameSize.width, list: viewModel.page.feedsArray) { feed in
            GadgetView(viewModel: FeedDisplayViewModel(feed: feed, refreshing: viewModel.refreshing))
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 38)
    }
}
