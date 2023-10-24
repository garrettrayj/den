//
//  TrendLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/20/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct TrendLayout: View {
    @ObservedObject var trend: Trend
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: [Item]

    var body: some View {
        if items.isEmpty {
            AllRead(largeDisplay: true)
        } else {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: items) { item in
                        if let feed = item.feedData?.feed {
                            if feed.wrappedPreviewStyle == .expanded {
                                FeedItemExpanded(item: item, feed: feed, profile: profile)
                            } else {
                                FeedItemCompressed(item: item, feed: feed, profile: profile)
                            }
                        }
                    }
                }
            }
        }
    }
}
