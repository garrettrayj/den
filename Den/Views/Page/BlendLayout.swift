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
            if items.isEmpty && hideRead {
                SplashNote(title: "No Unread", note: "Refresh to check for new items.")
            } else if items.isEmpty && !hideRead {
                SplashNote(title: "No Data", note: "Refresh to get items.")
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(geometry: geometry, list: Array(items)) { item in
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
