//
//  GroupedLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct GroupedLayout: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.isSearching) private var isSearching

    @ObservedObject var page: Page

    @Binding var hideRead: Bool

    let items: [Item]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                HStack(alignment: .top) {
                    ForEach(
                        Columnizer.columnize(
                            columnCount: Columnizer.calculateColumnCount(
                                width: geometry.size.width,
                                layoutScalingFactor: dynamicTypeSize.layoutScalingFactor
                            ),
                            list: visibleFeeds
                        ),
                        id: \.0
                    ) { _, feeds in
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(feeds) { feed in
                                FeedItemGroup(
                                    feed: feed,
                                    hideRead: hideRead,
                                    items: items.forFeed(feed: feed)
                                )
                            }
                        }
                    }
                }
                .padding([.horizontal, .top])
                .padding(.bottom, 8)
            }
            .id("GroupedLayout_\(page.id?.uuidString ?? "NoID")")
        }
    }
    
    private var visibleFeeds: [Feed] {
        if isSearching && hideRead {
            return page.feedsArray.filter { feed in
                items.unread().forFeed(feed: feed).count > 0
            }
        } else if isSearching {
            return page.feedsArray.filter { feed in
                items.forFeed(feed: feed).count > 0
            }
        } else {
            return page.feedsArray
        }
    }
}
