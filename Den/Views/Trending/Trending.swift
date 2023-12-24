//
//  Trending.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct Trending: View {
    @ObservedObject var profile: Profile

    @AppStorage("HideRead") private var hideRead: Bool = false
    
    private var visibleTrends: [Trend] {
        if hideRead {
            return profile.trends.containingUnread()
        }
        return profile.trends
    }

    var body: some View {
        Group {
            if profile.trends.isEmpty {
                ContentUnavailable {
                    Label {
                        Text("Nothing Trending", comment: "Content unavailable title.")
                    } icon: {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                    }
                } description: {
                    Text(
                        "No common subjects were found in item titles.",
                        comment: "Trending empty message."
                    )
                }
            } else if visibleTrends.isEmpty {
                AllRead(largeDisplay: true)
            } else {
                TrendingLayout(trends: visibleTrends)
            }
        }
        .toolbar {
            TrendingToolbar(profile: profile, hideRead: $hideRead)
        }
        .navigationTitle(Text("Trending", comment: "Navigation title."))
    }
}
