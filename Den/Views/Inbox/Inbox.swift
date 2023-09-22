//
//  Inbox.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Inbox: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var body: some View {
        WithItems(scopeObject: profile) { items in
            ZStack {
                if profile.feedsArray.isEmpty {
                    NoFeeds()
                } else if items.isEmpty {
                    ContentUnavailableView {
                        Label {
                            Text("Inbox Empty", comment: "Content unavailable title.")
                        } icon: {
                            Image(systemName: "tray")
                        }
                    } description: {
                        Text("Refresh to check for new items.", comment: "Content unavailable description.")
                    }
                } else if items.unread().isEmpty && hideRead {
                    AllRead(largeDisplay: true)
                } else {
                    GeometryReader { geometry in
                        ScrollView(.vertical) {
                            BoardView(
                                width: geometry.size.width,
                                list: items.visibilityFiltered(hideRead ? false : nil)
                            ) { item in
                                if let feed = item.feedData?.feed {
                                    if feed.wrappedPreviewStyle == .expanded {
                                        FeedItemExpanded(item: item, feed: feed, profile: profile)
                                    } else {
                                        FeedItemCompressed(item: item, feed: feed, profile: profile)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                InboxToolbar(profile: profile, hideRead: $hideRead, items: items)
            }
            .navigationTitle(Text("Inbox", comment: "Navigation title"))
        }
    }
}
