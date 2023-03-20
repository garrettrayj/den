//
//  GadgetLayoutView.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GadgetLayoutView: View {
    @ObservedObject var page: Page

    @Binding var previewStyle: PreviewStyle

    let items: FetchedResults<Item>
    let width: CGFloat

    var body: some View {
        ScrollView(.vertical) {
            BoardView(width: width, list: page.feedsArray) { feed in
                GadgetView(
                    feed: feed,
                    items: items.forFeed(feed: feed),
                    previewStyle: previewStyle
                )
            }.modifier(MainBoardModifier())
        }.id("gadgets_\(page.id?.uuidString ?? "na")_\(previewStyle)")
    }
}
