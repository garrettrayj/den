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
    @Environment(\.hideRead) private var hideRead

    @ObservedObject var page: Page

    let items: FetchedResults<Item>
    
    @ScaledMetric private var idealColumnWidth = Columnizer.idealColumnWidth

    var body: some View {
        GeometryReader { geometry in
            if #available(macOS 15.0, iOS 18.0, *) {
                deckContent(geometry: geometry)
                    #if os(macOS)
                    .toolbarBackgroundVisibility(.visible, for: .windowToolbar)
                    // Fix toolbar bottom border
                    .padding(.top, 1)
                    .offset(y: -1)
                    #else
                    .toolbarBackgroundVisibility(.visible, for: .navigationBar, .bottomBar)
                    #endif
            } else {
                deckContent(geometry: geometry)
                    .toolbarBackground(.visible)
                    #if os(macOS)
                    // Fix toolbar bottom border
                    .padding(.top, 1)
                    .offset(y: -1)
                    #endif
            }
        }
    }
    
    private func deckContent(geometry: GeometryProxy) -> some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(page.feedsArray) { feed in
                    ScrollView(.vertical, showsIndicators: false) {
                        DeckColumn(
                            feed: feed,
                            hideRead: hideRead,
                            items: items.forFeed(feed)
                        )
                        .padding(.vertical)
                        .drawingGroup()
                    }
                    .scrollClipDisabled()
                    .containerRelativeFrame(
                        .horizontal,
                        count: max(1, Int(geometry.size.width / idealColumnWidth)),
                        spacing: 8
                    )
                    .contentMargins(.bottom, geometry.safeAreaInsets.bottom)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled()
        .contentMargins(.horizontal, 16)
        .ignoresSafeArea(edges: .bottom)
    }
}
