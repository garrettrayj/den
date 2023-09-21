//
//  SpreadLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SpreadLayout: View {
    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: [Item]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                BoardView(width: geometry.size.width, list: page.feedsArray) { feed in
                    Gadget(
                        feed: feed,
                        profile: profile,
                        hideRead: $hideRead,
                        items: items.forFeed(feed: feed)
                    )
                }
            }
        }
    }
}
