//
//  ShowcaseView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseView: View {
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(viewModel.page.feedsArray) { feed in
                ShowcaseSectionView(viewModel: FeedViewModel(feed: feed, refreshing: viewModel.refreshing))
            }
        }
    }
}
