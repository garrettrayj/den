//
//  GadgetLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GadgetLayout: View {
    @ObservedObject var page: Page

    let hideRead: Bool
    let previewStyle: PreviewStyle

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                WithItems(
                    scopeObject: page,
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \Item.feedData?.id, ascending: false),
                        NSSortDescriptor(keyPath: \Item.published, ascending: false)
                    ],
                    readFilter: hideRead ? false : nil
                ) { items in
                    BoardView(width: geometry.size.width, list: page.feedsArray) { feed in
                        Gadget(
                            feed: feed,
                            items: items.forFeed(feed: feed),
                            previewStyle: previewStyle
                        )
                    }.modifier(MainBoardModifier())
                }
            }
        }
    }
}
