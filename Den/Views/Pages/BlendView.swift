//
//  BlendView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendView: View {
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

    @ViewBuilder
    var content: some View {
        if viewModel.page.limitedItemsArray.isEmpty {
            StatusBoxView(
                message: Text("No Items"),
                caption: Text("Tap \(Image(systemName: "arrow.clockwise")) to refresh"),
                symbol: "questionmark.square.dashed"
            )
            .frame(height: frameSize.height)
        } else {
            BoardView(width: frameSize.width, list: viewModel.page.limitedItemsArray) { item in
                BlendItemView(item: item)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 38)
        }
    }
}
