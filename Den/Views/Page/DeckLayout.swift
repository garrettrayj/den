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
                LazyHStack(alignment: .top, spacing: 0) {
                    ForEach(page.feedsArray) { feed in
                        DeckColumn(
                            feed: feed,
                            profile: profile,
                            isFirst: page.feedsArray.first == feed,
                            isLast: page.feedsArray.last == feed,
                            items: items.forFeed(feed: feed),
                            pageGeometry: geometry,
                            hideRead: hideRead
                        )
                        .containerRelativeFrame(
                            .horizontal,
                            count: columnCount(width: geometry.size.width),
                            spacing: 0
                        )
                        .offset(y: -1)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
            .ignoresSafeArea(edges: .vertical)
            .safeAreaPadding(.horizontal, 12)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
            .padding(.top, 1)
        }
    }

    private func columnCount(width: CGFloat) -> Int {
        let adjustedWidth = width / dynamicTypeSize.layoutScalingFactor
        return max(1, Int((adjustedWidth / log2(adjustedWidth)) / 27.2))
    }
}
