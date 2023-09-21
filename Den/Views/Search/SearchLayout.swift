//
//  SearchLayout.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct SearchLayout: View {
    @ObservedObject var profile: Profile
    @ObservedObject var search: Search

    @Binding var hideRead: Bool

    let items: [Item]

    var visibilityFilteredItems: [Item] {
        items.visibilityFiltered(hideRead ? false : nil)
    }

    var body: some View {
        ZStack {
            if items.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text(
                            "No Results for “\(search.wrappedQuery)”",
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
                ContentUnavailableView {
                    Label {
                        Text(
                            "No Unread Results for\n“\(search.wrappedQuery)”",
                            comment: "No unread search results title."
                        )
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                } description: {
                    Text("Turn off filtering to show hidden items.", comment: "No unread search results guidance.")
                }
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: visibilityFilteredItems) { item in
                            if let feed = item.feedData?.feed {
                                if feed.wrappedPreviewStyle == .expanded {
                                    FeedItemExpanded(item: item, feed: feed, profile: profile)
                                } else {
                                    FeedItemCompressed(item: item, feed: feed, profile: profile)
                                }
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                }
            }
        }
    }
}
