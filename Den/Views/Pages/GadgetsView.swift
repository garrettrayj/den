//
//  GadgetsView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetsView: View {
    #if !targetEnvironment(macCatalyst)
    @EnvironmentObject var refreshManager: RefreshManager
    #endif

    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        #if targetEnvironment(macCatalyst)
        ScrollView(.vertical) {
            gadgetsDisplay
        }
        #else
        RefreshableScrollView(
            onRefresh: { done in
                refreshManager.refresh(page: viewModel.page)
                done()
            },
            content: { gadgetsDisplay }
        )
        #endif
    }

    var gadgetsDisplay: some View {
        BoardView(list: viewModel.feedViewModels, content: { feedViewModel in
            GadgetView(viewModel: feedViewModel)
        })
        .padding([.horizontal, .bottom])
        .padding(.top, 8)
    }
}
