//
//  TrendLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/20/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendLayout: View {
    @Environment(\.hideRead) private var hideRead
    
    @ObservedObject var trend: Trend

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
