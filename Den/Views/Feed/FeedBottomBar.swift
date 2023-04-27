//
//  FeedBottomBar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedBottomBar: View {
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var body: some View {
        FilterReadButton(hideRead: $hideRead) {
            feed.objectWillChange.send()
        }
        Spacer()
        WithItems(scopeObject: feed, includeExtras: true) { items in
            FeedStatus(feed: feed, unreadCount: items.unread().count)
            Spacer()
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                feed.objectWillChange.send()
            }
        }
    }
}
