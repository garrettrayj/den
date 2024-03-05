//
//  SearchLayout.swift
//  Den
//
//  Created by Garrett Johnson on 1/3/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SearchLayout: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let query: String
    let items: FetchedResults<Item>

    var visibilityFilteredItems: [Item] {
        items.visibilityFiltered(hideRead ? false : nil)
    }

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailable {
                    Label {
                        Text(
                            "No Results",
                            comment: "No search results message title."
                        )
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                } description: {
                    Text(
                        "Check the spelling or try a new search.",
                        comment: "No search results guidance."
                    )
                }
            } else if hideRead && visibilityFilteredItems.isEmpty {
                ContentUnavailable {
                    Label {
                        Text(
                            "No Unread Results",
                            comment: "No unread search results title."
                        )
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                } description: {
                    Text(
                        """
                        Turn off filter to show hidden items.
                        """,
                        comment: "No unread search results guidance."
                    )
                }
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: visibilityFilteredItems) { item in
                            if let feed = item.feedData?.feed {
                                if feed.wrappedPreviewStyle == .expanded {
                                    FeedItemExpanded(item: item, feed: feed)
                                } else {
                                    FeedItemCompressed(item: item, feed: feed)
                                }
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                    #if os(macOS)
                    .navigationSubtitle(
                        Text("Showing results for “\(query)”", comment: "Navigation subtitle.")
                    )
                    #endif
                }
            }
        }
    }
}
