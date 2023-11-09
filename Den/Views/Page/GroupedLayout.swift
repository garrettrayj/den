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

    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: [Item]
    let geometry: GeometryProxy

    var body: some View {
        ScrollView(.vertical) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(
                    Columnizer.columnize(
                        columnCount: Columnizer.calculateColumnCount(
                            width: geometry.size.width,
                            layoutScalingFactor: dynamicTypeSize.layoutScalingFactor
                        ),
                        list: page.feedsArray
                    ),
                    id: \.0
                ) { _, feeds in
                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(feeds) { feed in
                            FeedItemGroup(
                                feed: feed,
                                profile: profile,
                                hideRead: hideRead,
                                items: items.forFeed(feed: feed)
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
}
