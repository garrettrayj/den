//
//  SpreadLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SpreadLayout: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: [Item]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(columnData(width: geometry.size.width), id: \.0) { _, feeds in
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(feeds) { feed in
                                SpreadLayoutFeed(
                                    feed: feed,
                                    profile: profile,
                                    hideRead: hideRead,
                                    items: items.forFeed(feed: feed),
                                    filteredItems: items.forFeed(feed: feed)
                                        .visibilityFiltered(hideRead ? false : nil)
                                )
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func columnData(width: CGFloat) -> [(Int, [Feed])] {
        let adjustedWidth = width / dynamicTypeSize.layoutScalingFactor
        let columns: Int = max(1, Int((adjustedWidth / log2(adjustedWidth)) / 30))
        var gridArray: [(Int, [Feed])] = []

        var currentCol: Int = 0
        while currentCol < columns {
            gridArray.append((currentCol, []))
            currentCol += 1
        }

        var currentIndex: Int = 0
        for object in page.feedsArray {
            gridArray[currentIndex].1.append(object)

            if currentIndex == (columns - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }

        return gridArray
    }
}
