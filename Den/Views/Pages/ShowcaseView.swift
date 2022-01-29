//
//  ShowcaseView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShowcaseView: View {
    #if !targetEnvironment(macCatalyst)
    @EnvironmentObject var refreshManager: RefreshManager
    #endif

    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        #if targetEnvironment(macCatalyst)
        ScrollView(.vertical) {
            showcaseDisplay.padding(.top, 8)
        }
        #else
        RefreshableScrollView(
            onRefresh: { done in
                refreshManager.refresh(page: viewModel.page)
                done()
            },
            content: { showcaseDisplay }
        )
        #endif
    }

    var showcaseDisplay: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(viewModel.feedViewModels) { feedViewModel in
                ShowcaseSectionView(viewModel: feedViewModel)
            }
        }
    }
}
