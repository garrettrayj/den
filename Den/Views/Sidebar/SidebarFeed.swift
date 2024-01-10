//
//  SidebarFeed.swift
//  Den
//
//  Created by Garrett Johnson on 1/6/24.
//  Copyright © 2024 Garrett Johnson
//

import SwiftUI

struct SidebarFeed: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var feed: Feed
    
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
            FeedFavicon(feed: feed)
        }
        .tag(DetailPanel.feed(feed))
        #if os(macOS)
        .contentShape(Rectangle())
        .draggable(
            TransferableFeed(objectURI: feed.objectID.uriRepresentation())
        )
        .contextMenu {
            DeleteFeedButton(feed: feed)
        }
        #endif
    }
}
