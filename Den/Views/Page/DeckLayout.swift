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

    @Bindable var page: Page

    @Binding var hideRead: Bool

    let items: [Item]
    
    @ScaledMetric private var idealColumnWidth = Columnizer.idealColumnWidth

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 8) {
                    ForEach(page.feedsArray) { feed in
                        ScrollView(.vertical, showsIndicators: false) {
                            DeckColumn(
                                feed: feed,
                                hideRead: hideRead,
                                items: items.forFeed(feed)
                            )
                            .padding(.vertical)
                        }
                        .scrollClipDisabled()
                        .containerRelativeFrame(
                            .horizontal,
                            count: max(1, Int(geometry.size.width / idealColumnWidth)),
                            spacing: 8
                        )
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
            .contentMargins(.horizontal, 16)
            .ignoresSafeArea(edges: .bottom)
            .toolbarBackground(.visible)
        }
    }
}
