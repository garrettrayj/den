//
//  TrendingLayout.swift
//  Den
//
//  Created by Garrett Johnson on 12/24/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendingLayout: View {
    let trends: FetchedResults<Trend>
    
    @AppStorage("HideRead") private var hideRead: Bool = false
    
    var body: some View {
        if trends.containingUnread.isEmpty && hideRead {
            AllRead(largeDisplay: true)
        } else {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: visibleTrends) { trend in
                        TrendBlock(
                            trend: trend,
                            items: trend.items,
                            feeds: trend.feeds
                        )
                    }
                }
            }
        }
    }
    
    private var visibleTrends: [Trend] {
        let visibleTrends = hideRead ? trends.containingUnread : Array(trends)

        return visibleTrends.sorted {
            ($0.feeds.count, $0.items.count) > ($1.feeds.count, $1.items.count)
        }
    }
}
