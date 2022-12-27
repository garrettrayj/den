//
//  FeedBottomBarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct FeedBottomBarView: View {
    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) {
            feed.objectWillChange.send()
        }
        Spacer()
        Text("\(feed.previewItems.unread().count) Unread")
            .font(.caption)
            .fixedSize()
        Spacer()
        ToggleReadButtonView(unreadCount: feed.previewItems.unread().count) {
            await SyncUtility.toggleReadUnread(items: feed.feedData?.previewItems ?? [])
            feed.objectWillChange.send()
        }
    }
}
