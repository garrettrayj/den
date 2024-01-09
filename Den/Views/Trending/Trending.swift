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

    @Binding var hideRead: Bool

    var body: some View {
        WithTrends(profile: profile) { trends in
            if trends.isEmpty {
                ContentUnavailable {
                    Label {
                        Text("No Trends", comment: "Content unavailable title.")
                    } icon: {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                    }
                } description: {
                    Text(
                        "No common subjects were found in titles.",
                        comment: "Trending empty message."
                    )
                }
            } else {
                TrendingLayout(profile: profile, hideRead: $hideRead, trends: trends)
                    .toolbar {
                        TrendingToolbar(profile: profile, hideRead: $hideRead, trends: trends)
                    }
            }
        }
        .navigationTitle(Text("Trending", comment: "Navigation title."))
    }
}
