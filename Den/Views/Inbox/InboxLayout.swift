//
//  InboxLayout.swift
//  Den
//
//  Created by Garrett Johnson on 12/24/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct InboxLayout: View {
    let items: [Item]
    
    var body: some View {
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
