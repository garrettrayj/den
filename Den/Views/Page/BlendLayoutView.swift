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

    let hideRead: Bool
    let previewStyle: PreviewStyle

    var body: some View {
        WithItems(
            scopeObject: page,
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Item.feedData?.id, ascending: false),
                NSSortDescriptor(keyPath: \Item.published, ascending: false)
            ],
            readFilter: hideRead ? false : nil
        ) { items in
            if items.isEmpty {
                SplashNoteView(title: "Nothing Here", note: "Refresh to check for new items.")
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: Array(items)) { item in
                            if previewStyle == .compressed {
                                FeedItemCompressedView(item: item)
                            } else {
                                FeedItemExpandedView(item: item)
                            }
                        }.modifier(MainBoardModifier())
                    }
                }
            }
        }
    }
}
