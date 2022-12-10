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
    @Environment(\.persistentContainer) private var container

    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool

    var unreadCount: Int {
        feed.feedData?.previewItems.count ?? 0
    }

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) {
            feed.objectWillChange.send()
        }
        Spacer()
        Text("\(unreadCount) Unread")
            .font(.caption)
            .fixedSize()
        Spacer()
        ToggleReadButtonView(unreadCount: unreadCount) {
            await SyncUtility.toggleReadUnread(
                container: container,
                items: feed.feedData?.previewItems ?? []
            )
            feed.objectWillChange.send()
        }
    }
}
