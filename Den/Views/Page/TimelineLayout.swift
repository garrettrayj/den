//
//  TimelineLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TimelineLayout: View {
    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: FetchedResults<Item>

    var body: some View {
        if items.isEmpty {
            SplashNote(Text("No Items", comment: "Timeline page layout empty message."))
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
                    }
                    .modifier(MainBoardModifier())
                }
                .id("TimelineLayoutSroll_\(page.id?.uuidString ?? "NoID")")
            }
        }
    }
}
