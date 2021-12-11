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
        if viewModel.page.previewItemsArray.count > 0 {
            BoardView(list: viewModel.page.previewItemsArray) { item in
                if item.feedData?.feed != nil {
                    ItemPreviewView(
                        item: item,
                        feedViewModel: FeedViewModel(feed: item.feedData!.feed!, refreshing: viewModel.refreshing)
                    )
                }
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 8)
        } else {
            VStack {
                Divider()
                Text("Page empty").padding(.vertical, 8)
            }.modifier(SimpleMessageModifier())

        }
    }
}
