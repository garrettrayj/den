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
    @ObservedObject var profile: Profile

    @AppStorage("HideRead") private var hideRead: Bool = false

    var visibleTrends: [Trend] {
        if hideRead {
            return profile.trends.containingUnread()
        }
        return profile.trends
    }

    var body: some View {
        VStack {
            if profile.trends.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("Nothing Trending", comment: "Trending empty title.")
                    } icon: {
                        Image(systemName: "circle.slash").scaleEffect(x: -1, y: 1)
                    }
                } description: {
                    Text(
                        "No common subjects were found in item titles.",
                        comment: "Trending empty description."
                    )
                }
            } else if visibleTrends.isEmpty {
                AllRead(largeDisplay: true)
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(geometry: geometry, list: visibleTrends) { trend in
                            TrendBlock(trend: trend)
                        }
                        .modifier(MainBoardModifier())
                    }
                }
            }
        }
        .toolbar(id: "Trending") {
            TrendingToolbar(profile: profile, hideRead: $hideRead)
        }
        .navigationTitle(Text("Trending", comment: "Navigation title."))
    }
}
