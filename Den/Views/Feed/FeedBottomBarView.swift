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
    
    @State var unreadCount: Int

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) {
            feed.objectWillChange.send()
        }
        Spacer()
        Text("\(unreadCount) Unread")
            .font(.caption)
            .fixedSize()
            .onReceive(
                NotificationCenter.default.publisher(for: .itemStatus, object: nil)
            ) { notification in
                guard
                    let feedObjectID = notification.userInfo?["feedObjectID"] as? NSManagedObjectID,
                    feedObjectID == feed.objectID,
                    let read = notification.userInfo?["read"] as? Bool
                else {
                    return
                }
                unreadCount += read ? -1 : 1
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .feedRefreshed, object: feed.objectID)
            ) { _ in
                unreadCount = feed.feedData?.previewItems.count ?? 0
            }
        Spacer()
        ToggleReadButtonView(unreadCount: $unreadCount) {
            await SyncUtility.toggleReadUnread(
                container: container,
                items: feed.feedData?.previewItems ?? []
            )
            feed.objectWillChange.send()
        }
    }
}
