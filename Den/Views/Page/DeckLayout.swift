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

    let items: FetchedResults<Item>

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
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
                        }
                    }
                    .scrollTargetLayout()
                }
                .safeAreaPadding(.leading, geometry.safeAreaInsets.leading + 12)
                .safeAreaPadding(.trailing, geometry.safeAreaInsets.trailing + 12)
                .scrollTargetBehavior(.viewAligned)
                .scrollClipDisabled()
                .edgesIgnoringSafeArea(.all)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                #endif
            }
            .background(alignment: .topLeading) { horizontalSpacer }
            .background(alignment: .topTrailing) { horizontalSpacer }
                Divider()
            }
    }

    private var horizontalSpacer: some View {
        HStack {
            Text(verbatim: "M").font(.title3).padding(.vertical, 12).foregroundStyle(.clear)
        }
        .frame(width: 12)
        .background(.thickMaterial)
        .background(.quaternary)
    }

    private func columnCount(width: CGFloat) -> Int {
        let adjustedWidth = width / dynamicTypeSize.layoutScalingFactor
        return max(1, Int((adjustedWidth / log2(adjustedWidth)) / 27.2))
    }
}
