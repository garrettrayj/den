//
//  InboxNavView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct InboxNavView: View {
    @Environment(\.editMode) private var editMode
    @EnvironmentObject private var haptics: Haptics
    @ObservedObject var profile: Profile
    
    @State var unreadCount: Int

    var body: some View {
        NavigationLink(value: Panel.allItems) {
            Label {
                Text("Inbox").lineLimit(1)
            } icon: {
                Image(systemName: unreadCount > 0 ? "tray.full": "tray")
            }
        }
        .badge(unreadCount)
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
            NotificationCenter.default.publisher(for: .pagesRefreshed, object: nil)
        ) { _ in
            unreadCount = profile.previewItems.unread().count
        }
        .onChange(of: unreadCount) { newValue in
            UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.applicationIconBadgeNumber = newValue
                    }
                }
            }
        }
        .accessibilityIdentifier("inbox-button")
    }
}
