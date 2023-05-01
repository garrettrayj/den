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

    let items: [Item]

    var body: some View {
        if items.isEmpty {
            AllReadSplashNote()
        } else {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    BoardView(geometry: geometry, list: items) { item in
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
