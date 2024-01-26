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
    @ObservedObject var profile: Profile
    
    @Binding var hideRead: Bool
    
    let trends: [Trend]
    
    var body: some View {
        if trends.containingUnread().isEmpty && hideRead {
            AllRead(largeDisplay: true)
        } else {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: visibleTrends) { trend in
                        TrendBlock(
                            profile: profile,
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
        let visibleTrends = hideRead ? trends.containingUnread() : trends

        return visibleTrends.sorted { $0.items.count > $1.items.count }
    }
}
