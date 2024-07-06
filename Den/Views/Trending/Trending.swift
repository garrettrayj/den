//
//  Trending.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Trending: View {
    var body: some View {
        WithTrends { trends in
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
                TrendingLayout(trends: trends)
                    .toolbar {
                        TrendingToolbar(trends: trends)
                    }
            }
        }
        .navigationTitle(Text("Trending", comment: "Navigation title."))
    }
}
