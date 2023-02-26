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

    @Binding var hideRead: Bool

    var body: some View {
        WithItems(scopeObject: feed) { _, unreadItems in
            FilterReadButtonView(hideRead: $hideRead) {
                feed.objectWillChange.send()
            }
            Spacer()
            Text("\(unreadItems.count) Unread")
                .font(.caption)
                .fixedSize()
            Spacer()
            ToggleReadButtonView(unreadCount: unreadItems.count) {
                await HistoryUtility.toggleReadUnread(items: feed.feedData?.itemsArray ?? [])
                feed.objectWillChange.send()
            }
        }
    }
}
