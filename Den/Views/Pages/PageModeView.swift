//
//  PageModeView.swift
//  Den
//
//  Created by Garrett Johnson on 2/10/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageModeView: View {
    var viewModel: PageViewModel
    @Binding var viewMode: Int
    var frameSize: CGSize

    var body: some View {
        if viewMode == PageViewMode.blend.rawValue {
            BoardView(width: frameSize.width, list: viewModel.page.limitedItemsArray) { item in
                BlendItemView(item: item)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 38)
        } else if viewMode == PageViewMode.showcase.rawValue {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.feedViewModels) { feedViewModel in
                    ShowcaseSectionView(viewModel: feedViewModel, width: frameSize.width)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 22)
        } else {
            BoardView(width: frameSize.width, list: viewModel.feedViewModels) { feedViewModel in
                GadgetView(viewModel: feedViewModel)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 38)
        }
    }
}
