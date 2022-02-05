//
//  BlendView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendView: View {
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
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
    }
}
