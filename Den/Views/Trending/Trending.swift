//
//  Trending.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct Trending: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var visibleTrends: [Trend] {
        if hideRead {
            return profile.trends.containingUnread()
        }
        return profile.trends
    }

    var body: some View {
        GeometryReader { geometry in
            if profile.trends.isEmpty {
                SplashNote(
                    title: "Nothing Trending",
                    note: "No common subjects were found in item titles."
                )
            } else if visibleTrends.isEmpty {
                AllReadSplashNote()
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: visibleTrends) { trend in
                        TrendBlock(trend: trend)
                    }
                    .modifier(MainBoardModifier())
                }
            }
        }
        .navigationTitle("Trending")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                TrendingBottomBar(profile: profile, refreshing: $refreshing, hideRead: $hideRead)
            }
        }
    }
}
