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

    let items: FetchedResults<Item>

    var body: some View {
        if items.isEmpty {
            SplashNote(title: Text("No Items"))
        } else if items.unread().isEmpty && hideRead {
            AllReadSplashNote()
        } else {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    BoardView(
                        geometry: geometry,
                        list: items.visibilityFiltered(hideRead ? false : nil)
                    ) { item in
                        if let feed = item.feedData?.feed {
                            if feed.wrappedPreviewStyle == .expanded {
                                FeedItemExpanded(item: item, feed: feed, profile: profile)
                            } else {
                                FeedItemCompressed(item: item, feed: feed, profile: profile)
                            }
                        }
                    }.modifier(MainBoardModifier())
                }
                .id("BlendLayoutSroll_\(page.id?.uuidString ?? "NoID")")
            }
        }
    }
}
