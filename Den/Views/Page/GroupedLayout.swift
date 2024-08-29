//
//  GroupedLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GroupedLayout: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.hideRead) private var hideRead

    @ObservedObject var page: Page
    
    @ScaledMetric private var idealColumnWidth = Columnizer.idealColumnWidth

    let items: FetchedResults<Item>

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                HStack(alignment: .top) {
                    ForEach(
                        Columnizer.columnize(
                            columnCount: Int(geometry.size.width / idealColumnWidth),
                            list: page.feedsArray
                        ),
                        id: \.0
                    ) { _, feeds in
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(feeds) { feed in
                                FeedItemGroup(
                                    feed: feed,
                                    hideRead: hideRead,
                                    items: items.forFeed(feed)
                                )
                            }
                        }
                    }
                }
                .padding([.horizontal, .top])
                .padding(.bottom, 8)
            }
        }
    }
}
