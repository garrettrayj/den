//
//  Inbox.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct Inbox: View {
    @AppStorage("HideRead") private var hideRead: Bool = false
    
    @Query()
    private var feeds: [Feed]

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
            .toolbar {
                InboxToolbar(
                    items: items
                )
            }
            .navigationTitle(Text("Inbox", comment: "Navigation title."))
        }
    }
}
