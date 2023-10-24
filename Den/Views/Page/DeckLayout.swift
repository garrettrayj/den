//
//  DeckLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
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
                            DeckColumn(
                                feed: feed,
                                profile: profile,
                                hideRead: hideRead,
                                items: items.forFeed(feed: feed)
                            )
                            .padding(.vertical)
                        }
                        .scrollClipDisabled()
                        .containerRelativeFrame(
                            .horizontal,
                            count: Columnizer.calculateColumnCount(
                                width: geometry.size.width,
                                layoutScalingFactor: dynamicTypeSize.layoutScalingFactor
                            ),
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
}
