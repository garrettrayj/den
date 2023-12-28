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

    @Binding var hideRead: Bool
    @Binding var searchQuery: String

    let items: [Item]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 8) {
                    ForEach(visibleFeeds) { feed in
                        ScrollView(.vertical, showsIndicators: false) {
                            DeckColumn(
                                feed: feed,
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
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
            .contentMargins(.horizontal, 16)
            .ignoresSafeArea(edges: .bottom)
            .id("DeckLayout_\(page.id?.uuidString ?? "NoID")")
        }
    }
    
    private var visibleFeeds: [Feed] {
        if !searchQuery.isEmpty && hideRead {
            return page.feedsArray.filter { feed in
                items.unread().forFeed(feed: feed).count > 0
            }
        } else if !searchQuery.isEmpty {
            return page.feedsArray.filter { feed in
                items.forFeed(feed: feed).count > 0
            }
        } else {
            return page.feedsArray
        }
    }
}
