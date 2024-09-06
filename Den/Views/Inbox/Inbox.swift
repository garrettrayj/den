//
//  Inbox.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct Inbox: View {
    @Environment(\.hideRead) private var hideRead
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var feeds: FetchedResults<Feed>

    var body: some View {
        WithItems { items in
            Group {
                if feeds.isEmpty {
                    NoFeeds(symbol: "tray")
                } else if items.isEmpty {
                    ContentUnavailable {
                        Label {
                            Text("Inbox Empty", comment: "Content unavailable title.")
                        } icon: {
                            Image(systemName: "tray")
                        }
                    } description: {
                        Text(
                            "Refresh to check for new items.",
                            comment: "Content unavailable description."
                        )
                    }
                } else if items.unread.isEmpty && hideRead {
                    AllRead(largeDisplay: true)
                } else {
                    InboxLayout(items: items.visibilityFiltered(hideRead ? false : nil))
                }
            }
            .toolbar { toolbarContent(items: items) }
            .navigationTitle(Text("Inbox", comment: "Navigation title."))
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent(items: FetchedResults<Item>) -> some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            ToggleReadFilterButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty && !items.isEmpty) {
                HistoryUtility.toggleRead(items: items, context: viewContext)
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                ToggleReadFilterButton()
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleRead(items: items, context: viewContext)
                }
            }
        } else {
            ToolbarItem {
                ToggleReadFilterButton()
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty && !items.isEmpty) {
                    HistoryUtility.toggleRead(items: items, context: viewContext)
                }
            }
        }
        #endif
    }
}
