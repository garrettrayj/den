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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.showUnreadCounts) private var showUnreadCounts
    
    @ObservedObject var feed: Feed
    
    var unreadCount: Int
    
    var body: some View {
        Label {
            #if os(macOS)
            TextField(text: $feed.wrappedTitle) {
                feed.displayTitle
            }
            .onSubmit {
                if viewContext.hasChanges {
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
