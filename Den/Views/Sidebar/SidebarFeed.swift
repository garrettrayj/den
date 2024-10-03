//
//  SidebarFeed.swift
//  Den
//
//  Created by Garrett Johnson on 1/6/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarFeed: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.showUnreadCounts) private var showUnreadCounts
    
    @ObservedObject var feed: Feed
    
    var unreadCount: Int
    
    @FocusState private var titleFieldFocused: Bool
    
    var body: some View {
        Label {
            #if os(macOS)
            TextField(text: $feed.wrappedTitle) {
                feed.displayTitle
            }
            .focused($titleFieldFocused)
            .onChange(of: titleFieldFocused) { _, isFocused in
                if !isFocused && viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
            #else
            feed.displayTitle
            #endif
        } icon: {
            Favicon(url: feed.feedData?.favicon) {
                FeedFaviconPlaceholder()
            }
        }
        .badge(showUnreadCounts ? unreadCount : 0)
        .tag(DetailPanel.feed(feed.objectID.uriRepresentation()))
        .modifier(DraggableFeedModifier(feed: feed))
        .contextMenu {
            DeleteFeedButton(feed: feed)
        }
        .accessibilityIdentifier("SidebarFeed")
    }
}
