//
//  InboxBottomBarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct InboxBottomBarView: View {
    @Environment(\.persistentContainer) private var container
    
    @ObservedObject var profile: Profile
    
    @Binding var hideRead: Bool
    
    @State var unreadCount: Int

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) {
            profile.objectWillChange.send()
        }
        Spacer()
        Text("\(unreadCount) Unread")
            .font(.caption)
            .fixedSize()
            .onReceive(
                NotificationCenter.default.publisher(for: .itemStatus, object: nil)
            ) { notification in
                guard
                    let profileObjectID = notification.userInfo?["profileObjectID"] as? NSManagedObjectID,
                    profileObjectID == profile.objectID,
                    let read = notification.userInfo?["read"] as? Bool
                else {
                    return
                }
                unreadCount += read ? -1 : 1
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .pagesRefreshed, object: profile.objectID)
            ) { _ in
                unreadCount = profile.previewItems.unread().count
            }
        Spacer()
        ToggleReadButtonView(unreadCount: $unreadCount) {
            await SyncUtility.toggleReadUnread(container: container, items: profile.previewItems)
        }
    }
}

