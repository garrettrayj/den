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

    var visibleTrends: [Trend] {
        if hideRead {
            return profile.trends.containingUnread()
        }
        return profile.trends
    }

    var body: some View {
        VStack {
            if profile.trends.isEmpty {
                SplashNote(
                    title: Text("Nothing Trending"),
                    note: Text("No common subjects were found in item titles.")
                )
            } else if visibleTrends.isEmpty {
                AllReadSplashNote()
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
        .toolbar {
            TrendingBottomBar(profile: profile, hideRead: $hideRead)
        }
        .navigationTitle(Text("Trending"))
    }
}
