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

    var body: some View {
        GeometryReader { geometry in
            if profile.trends.isEmpty {
                SplashNoteView(
                    title: Text("Trends Empty"),
                    caption: Text("No common subjects were found in item titles.")
                )
            } else {
                if visibleTrends.isEmpty {
                    AllReadSplashNoteView(hiddenItemCount: readTrends.count)
                } else {
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: visibleTrends) { trend in
                            TrendBlockView(trend: trend)
                        }
                        Spacer()
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Trends")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                TrendsBottomBarView(profile: profile, hideRead: $hideRead)
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
