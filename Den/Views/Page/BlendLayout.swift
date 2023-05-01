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
    @ObservedObject var profile: Profile

    let hideRead: Bool

    let items: [Item]

    var body: some View {
        if items.isEmpty && hideRead {
            SplashNote(title: "All Read", note: "Refresh to check for new items.")
        } else if items.isEmpty && !hideRead {
            SplashNote(title: "No Data", note: "Refresh to get items.")
        } else {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    BoardView(geometry: geometry, list: items) { item in
                        if item.feedData?.feed?.wrappedPreviewStyle == .expanded {
                            FeedItemExpanded(item: item, profile: profile)
                        } else {
                            FeedItemCompressed(item: item, profile: profile)
                        }
                    }.modifier(MainBoardModifier())
                }
                .id("BlendLayoutSroll_\(page.id?.uuidString ?? "NoID")")
            }
        }
    }
}
