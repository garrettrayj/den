//
//  GlobalSidebarItemView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct AllItemsNavView: View {
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    @State var unreadCount: Int

    @Binding var refreshing: Bool

    var body: some View {
        NavigationLink(value: Panel.allItems) {
            Label {
                HStack {
                    Text("All Items").modifier(SidebarItemLabelTextModifier())
                    Spacer()
                    Text(String(profile.previewItems.unread().count))
                        .modifier(CapsuleModifier())
                }.lineLimit(1)
            } icon: {
                Image(systemName: unreadCount > 0 ? "tray.full": "tray").imageScale(.large)
            }
        }
        .accessibilityIdentifier("timeline-button")
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
            NotificationCenter.default.publisher(for: .profileRefreshed, object: profile.objectID)
        ) { _ in
            unreadCount = profile.previewItems.unread().count
        }
    }
}
