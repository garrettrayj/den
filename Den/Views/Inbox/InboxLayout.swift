//
//  InboxLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct InboxLayout: View {
    @ObservedObject var profile: Profile

    let hideRead: Bool

    let items: FetchedResults<Item>

    var body: some View {
        if profile.feedsArray.isEmpty {
            NoFeeds()
        } else if items.isEmpty {
            SplashNote(title: Text("No Items", comment: "Inbox empty note"))
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
}
