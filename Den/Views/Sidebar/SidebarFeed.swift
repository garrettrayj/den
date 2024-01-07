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
                Text(feed.wrappedTitle)
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
            Text(feed.wrappedTitle)
            #endif
        } icon: {
            #if os(macOS)
            FaviconImage(url: feed.feedData?.favicon, size: .small)
            #else
            FaviconImage(url: feed.feedData?.favicon, size: .large)
            #endif
        }
        .tag(DetailPanel.feed(feed))
        #if os(macOS)
        .contextMenu {
            DeleteFeedButton(feed: feed)
        }
        .contentShape(Rectangle())
        .draggable(
            TransferableFeed(objectURI: feed.objectID.uriRepresentation())
        )
        #endif
    }
}
