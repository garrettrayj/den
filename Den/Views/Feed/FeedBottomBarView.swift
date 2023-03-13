//
//  FeedBottomBarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedBottomBarView: View {
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    var body: some View {
        WithItems(scopeObject: feed) { items in
            FilterReadButtonView(hideRead: $hideRead) {
                feed.objectWillChange.send()
            }
            Spacer()
            FeedStatusView(feed: feed, refreshing: $refreshing, unreadCount: items.unread().count)
            Spacer()
            ToggleReadButtonView(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                feed.objectWillChange.send()
            }
        }
    }
}
