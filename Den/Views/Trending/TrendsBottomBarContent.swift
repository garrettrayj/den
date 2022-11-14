//
//  TrendsBottomBarContent.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendsBottomBarContent: ToolbarContent {
    @Environment(\.persistentContainer) private var container
    
    @ObservedObject var profile: Profile
    
    @Binding var hideRead: Bool
    @Binding var refreshing: Bool
    
    @State var unreadCount: Int
    @State private var toggling: Bool = false

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            FilterReadButtonView(hideRead: $hideRead, refreshing: $refreshing)
            Spacer()
            Text("\(unreadCount) Unread")
                .font(.caption)
                .fixedSize()
                .onReceive(
                    NotificationCenter.default
                        .publisher(for: .itemStatus)
                        .throttle(for: 1.0, scheduler: RunLoop.main, latest: true)
                ) { notification in
                    guard
                        let profileObjectID = notification.userInfo?["profileObjectID"] as? NSManagedObjectID,
                        profileObjectID == profile.objectID
                    else {
                        return
                    }
                    unreadCount = profile.trends.unread().count
                }
                .onReceive(
                    NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)
                ) { _ in
                    unreadCount = profile.trends.unread().count
                }
            Spacer()
            ToggleReadButtonView(unreadCount: $unreadCount, refreshing: $refreshing) {
                await SyncUtility.toggleReadUnread(container: container, items: profile.previewItems)
            }
        }
    }
}
