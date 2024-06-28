//
//  SidebarFeed.swift
//  Den
//
//  Created by Garrett Johnson on 1/6/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SidebarFeed: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var feed: Feed
    
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    
    var body: some View {
        Label {
            #if os(macOS)
            TextField(text: $feed.wrappedTitle) {
                feed.displayTitle
            }
            #else
            feed.displayTitle
            #endif
        } icon: {
            Favicon(url: feed.feedData?.favicon) {
                FeedFaviconPlaceholder()
            }
        }
        .badge(showUnreadCounts ? feed.feedData?.items?.featured.unread.count ?? 0 : 0)
        .tag(DetailPanel.feed(feed))
        .modifier(DraggableFeedModifier(feed: feed))
        .contextMenu {
            DeleteFeedButton(feed: feed)
        }
        .accessibilityIdentifier("SidebarFeed")
    }
}
