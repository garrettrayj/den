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

    let hideRead: Bool

    let items: FetchedResults<Item>

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                BoardView(geometry: geometry, list: page.feedsArray) { feed in
                    Gadget(
                        feed: feed,
                        profile: profile,
                        items: items.forFeed(feed: feed).visibilityFiltered(hideRead ? false : nil)
                    )
                }.modifier(MainBoardModifier())
            }.id("GadgetLayoutSroll_\(page.id?.uuidString ?? "NoID")")
        }
    }
}
