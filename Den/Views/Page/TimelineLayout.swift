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
            ContentUnavailableView {
                Label {
                    Text("No Items", comment: "Content unavailable title.")
                } icon: {
                    Image(systemName: "circle.slash").scaleEffect(x: -1, y: 1)
                }
            }
        } else if items.unread().isEmpty && hideRead {
            AllRead(largeDisplay: true)
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
            }
        }
    }
}
