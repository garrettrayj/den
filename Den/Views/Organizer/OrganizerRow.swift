//
//  OrganizerRow.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct OrganizerRow: View {
    @ObservedObject var feed: Feed
    
    var body: some View {
        HStack {
            Favicon(url: feed.feedData?.favicon) {
                FeedFaviconPlaceholder()
            }
            #if os(macOS)
            TextField(
                text: $feed.wrappedTitle,
                prompt: Text("Untitled", comment: "Default feed title.")
            ) {
                Text("Title", comment: "Text field label.")
            }
            #else
            feed.displayTitle
            #endif
            Spacer()
            Group {
                if let feedData = feed.feedData {
                    OrganizerRowStatus(feed: feed, feedData: feedData)
                } else {
                    Image(systemName: "questionmark.folder").foregroundStyle(.yellow)
                    Text("No Data", comment: "Organizer row status.")
                }
            }
            .font(.callout)
            .imageScale(.medium)
            .foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .tag(feed)
    }
}
