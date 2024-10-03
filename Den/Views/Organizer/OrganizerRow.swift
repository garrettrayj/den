//
//  OrganizerRow.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct OrganizerRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.operatingSystem) private var operatingSystem
    
    @ObservedObject var feed: Feed
    
    @FocusState private var titleFieldFocused: Bool
    
    var body: some View {
        HStack {
            Favicon(url: feed.feedData?.favicon) {
                FeedFaviconPlaceholder()
            }
            if operatingSystem == .macOS {
                TextField(
                    text: $feed.wrappedTitle,
                    prompt: Text("Untitled", comment: "Default feed title.")
                ) {
                    Text("Title", comment: "Text field label.")
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
            } else {
                feed.displayTitle
            }
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
