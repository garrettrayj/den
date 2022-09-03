//
//  TrendsLayoutView.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendsLayoutView: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    let frameSize: CGSize

    var body: some View {
        if visibleTrends.isEmpty {
            AllReadView(hiddenItemCount: readTrends.count)
        } else {
            ScrollView(.vertical) {
                BoardView(width: frameSize.width, list: visibleTrends) { trend in
                    TrendBlockView(trend: trend, refreshing: $refreshing)
                }
                .padding()
            }
        }
    }

    private var readTrends: [Trend] {
        profile.trends.filter { trend in
            trend.items.unread().isEmpty
        }
    }

    private var visibleTrends: [Trend] {
        profile.trends.filter { trend in
            hideRead ? !trend.items.unread().isEmpty : true
        }
    }
}
