//
//  BlendLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BlendLayout: View {
    @ObservedObject var page: Page

    let hideRead: Bool
    let previewStyle: PreviewStyle

    var body: some View {
        WithItems(
            scopeObject: page,
            readFilter: hideRead ? false : nil
        ) { items in
            if items.isEmpty {
                SplashNote(title: "Nothing Here", note: "Refresh to check for new items.")
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: Array(items)) { item in
                            if previewStyle == .compressed {
                                FeedItemCompressed(item: item)
                            } else {
                                FeedItemExpanded(item: item)
                            }
                        }.modifier(MainBoardModifier())
                    }
                }
            }
        }
    }
}
