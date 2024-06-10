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
    @AppStorage("HideRead") private var hideRead: Bool = false

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
                TrendingLayout(hideRead: $hideRead, trends: trends)
                    .toolbar {
                        TrendingToolbar(hideRead: $hideRead, trends: trends)
                    }
            }
        }
        .navigationTitle(Text("Trending", comment: "Navigation title."))
    }
}
