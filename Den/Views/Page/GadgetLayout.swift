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
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

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
                    BoardView(geometry: geometry, list: page.feedsArray) { feed in
                        Gadget(
                            feed: feed,
                            profile: profile,
                            items: items.forFeed(feed: feed)
                        )
                    }.modifier(MainBoardModifier())
                }
            }.id("GadgetLayoutSroll_\(page.id?.uuidString ?? "NoID")")
        }
    }
}
