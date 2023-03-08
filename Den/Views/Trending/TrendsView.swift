//
//  TrendsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct TrendsView: View {
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
                SplashNoteView(
                    title: "Trends Empty",
                    note: "No common subjects were found in item titles."
                )
            } else if visibleTrends.isEmpty {
                AllReadSplashNoteView()
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: visibleTrends) { trend in
                        TrendBlockView(trend: trend)
                    }.modifier(MainBoardModifier())
                }
            }
        }
        .navigationTitle("Trends")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                TrendsBottomBarView(profile: profile, refreshing: $refreshing, hideRead: $hideRead)
            }
        }
    }
}
