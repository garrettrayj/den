//
//  DeckLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
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
            .toolbarBackground(.visible, for: .automatic, .bottomBar)
            #if os(macOS)
            // Fix toolbar bottom border
            .padding(.top, 1)
            .offset(y: -1)
            #endif
        }
    }
}
