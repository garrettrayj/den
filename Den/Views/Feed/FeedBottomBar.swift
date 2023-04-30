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

    let items: FetchedResults<Item>

    var body: some View {
        FilterReadButton(hideRead: $hideRead) {
            feed.objectWillChange.send()
        }
        Spacer()
        FeedStatus(feed: feed, unreadCount: items.unread().count)
        Spacer()
        ToggleReadButton(unreadCount: items.unread().count) {
            await HistoryUtility.toggleReadUnread(items: Array(items))
            feed.objectWillChange.send()
        }
    }
}
