//
//  TrendLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendLayout: View {
    @ObservedObject var trend: Trend
    @ObservedObject var profile: Profile

    let hideRead: Bool

    var body: some View {
        WithItems(
            scopeObject: trend,
            readFilter: hideRead ? false : nil
        ) { items in
            if items.isEmpty {
                AllReadSplashNote()
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(geometry: geometry, list: Array(items)) { item in
                            if item.feedData?.feed?.wrappedPreviewStyle == .expanded {
                                FeedItemExpanded(item: item, profile: profile)
                            } else {
                                FeedItemCompressed(item: item, profile: profile)
                            }
                        }.modifier(MainBoardModifier())
                    }
                }
            }
        }
    }
}
