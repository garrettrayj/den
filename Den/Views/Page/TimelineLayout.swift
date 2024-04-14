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

    @Binding var hideRead: Bool

    let items: FetchedResults<Item>

    var body: some View {
        if items.isEmpty {
            ContentUnavailable {
                Label {
                    Text("No Items", comment: "Content unavailable title.")
                } icon: {
                    Image(systemName: "folder")
                }
            }
        } else if items.unread.isEmpty && hideRead {
            AllRead(largeDisplay: true)
        } else {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    BoardView(
                        width: geometry.size.width,
                        list: items.visibilityFiltered(hideRead ? false : nil)
                    ) { item in
                        if let feed = item.feedData?.feed {
                            if feed.wrappedPreviewStyle == .expanded {
                                FeedItemExpanded(item: item, feed: feed)
                            } else {
                                FeedItemCompressed(item: item, feed: feed)
                            }
                        }
                    }
                }
            }
        }
    }
}
