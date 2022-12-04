//
//  InboxNavView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct InboxNavView: View {
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var profile: Profile
    
    let searchModel: SearchModel
    
    @Binding var selection: Panel?
    
    @State var unreadCount: Int
    
    @State private var searchInput = ""

    var body: some View {
        if editMode?.wrappedValue == .inactive {
            Label {
                Text("Inbox").lineLimit(1).badge(unreadCount)
            } icon: {
                Image(systemName: unreadCount > 0 ? "tray.full": "tray")
            }
            .searchable(
                text: $searchInput,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .onSubmit(of: .search) {
                searchModel.query = searchInput
                selection = .search
            }
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
            .tag(Panel.inbox)
        }
    }
}
