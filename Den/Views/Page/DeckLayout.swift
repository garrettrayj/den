//
//  DeckLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeckLayout: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: [Item]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 8) {
                    ForEach(page.feedsArray) { feed in
                        ScrollView(.vertical, showsIndicators: false) {
                            Gadget(
                                feed: feed,
                                profile: profile,
                                hideRead: $hideRead,
                                items: items.forFeed(feed: feed)
                            )
                            .padding(.vertical)
                        }
                        .scrollClipDisabled()
                        .containerRelativeFrame(
                            .horizontal,
                            count: columnCount(width: geometry.size.width),
                            spacing: 8
                        )
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
            .contentMargins(.horizontal, 16)
        }
    }

    private func columnCount(width: CGFloat) -> Int {
        let adjustedWidth = width / dynamicTypeSize.layoutScalingFactor
        return max(1, Int((adjustedWidth / log2(adjustedWidth)) / 30))
    }
}
