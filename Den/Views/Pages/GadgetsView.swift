//
//  GadgetsView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetsView: View {
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        BoardView(list: viewModel.page.feedsArray, content: { feed in
            GadgetView(viewModel: FeedViewModel(feed: feed, refreshing: viewModel.refreshing))
        }).padding([.horizontal, .bottom])
    }
}
