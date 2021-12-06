//
//  HeapView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct HeapView: View {
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        if viewModel.page.previewItemsArray.count > 0 {
            BoardView(list: viewModel.page.previewItemsArray) { item in
                if item.feedData?.feed != nil {
                    HeapItemView(
                        feedViewModel: FeedViewModel(feed: item.feedData!.feed!, refreshing: viewModel.refreshing),
                        item: item
                    )
                }
            }.padding()
        } else {
            VStack {
                Divider()
                Text("Page empty").padding(.vertical, 8)
            }.modifier(SimpleMessageModifier())

        }
    }
}
