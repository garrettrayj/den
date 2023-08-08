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

    @Binding var showingNewFeedSheet: Bool

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        WithItems(scopeObject: profile) { items in
            ZStack {
                if profile.feedsArray.isEmpty {
                    NoFeeds(showingNewFeedSheet: $showingNewFeedSheet)
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
                    AllReadSplashNote()
                } else {
                    GeometryReader { geometry in
                        ScrollView(.vertical) {
                            BoardView(
                                geometry: geometry,
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
                            .modifier(MainBoardModifier())
                        }
                    }
                }
            }
            .toolbar(id: "Inbox") {
                InboxToolbar(profile: profile, hideRead: $hideRead, items: items)
            }
            .navigationTitle(Text("Inbox"))
        }
    }
}
