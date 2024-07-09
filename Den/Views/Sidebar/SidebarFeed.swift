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
    
    @State var title: String
    
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Label {
            #if os(macOS)
            TextField(text: $title) {
                feed.displayTitle
            }
            .focused($isFocused)
            .onChange(of: isFocused) {
                feed.wrappedTitle = title
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
        .tag(DetailPanel.feed(feed.persistentModelID))
        .modifier(DraggableFeedModifier(feed: feed))
        .contextMenu {
            DeleteFeedButton(feed: feed)
        }
        .accessibilityIdentifier("SidebarFeed")
    }
}
