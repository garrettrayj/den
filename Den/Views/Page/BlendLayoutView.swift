//
//  BlendLayoutView.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BlendLayoutView: View {
    @ObservedObject var page: Page

    @Binding var previewStyle: PreviewStyle

    let items: FetchedResults<Item>
    let width: CGFloat

    var body: some View {
        ScrollView(.vertical) {
            BoardView(width: width, list: Array(items)) { item in
                if previewStyle == .compressed {
                    FeedItemCompressedView(item: item)
                } else {
                    FeedItemExpandedView(item: item)
                }
            }.modifier(MainBoardModifier())
        }.id("blend_\(page.id?.uuidString ?? "na")_\(previewStyle)")
    }
}
