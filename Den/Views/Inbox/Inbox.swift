//
//  Inbox.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct Inbox: View {
    @ObservedObject var profile: Profile
    
    @Binding var hideRead: Bool

    var body: some View {
        WithItems(scopeObject: profile) { items in
            Group {
                if profile.feedsArray.isEmpty {
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
                } else if items.unread().isEmpty && hideRead {
                    AllRead(largeDisplay: true)
                } else {
                    InboxLayout(items: items.visibilityFiltered(hideRead ? false : nil))
                }
            }
            .toolbar {
                InboxToolbar(
                    profile: profile,
                    hideRead: $hideRead,
                    items: items
                )
            }
            .navigationTitle(Text("Inbox", comment: "Navigation title"))
        }
    }
}
