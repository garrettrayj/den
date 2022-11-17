//
//  TrendBottomBarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct TrendBottomBarView: View {
    @Environment(\.persistentContainer) private var container
    
    @ObservedObject var trend: Trend
    
    @Binding var hideRead: Bool
    @Binding var refreshing: Bool
    
    @State var unreadCount: Int

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead, refreshing: $refreshing) {
            trend.objectWillChange.send()
        }
        Spacer()
        Text("\(unreadCount) Unread")
            .font(.caption)
            .fixedSize()
            .onReceive(
                NotificationCenter.default.publisher(for: .itemStatus, object: nil)
            ) { notification in
                guard
                    let itemObjectID = notification.userInfo?["itemObjectID"] as? NSManagedObjectID,
                    trend.items.map({ $0.objectID }).contains(itemObjectID),
                    let read = notification.userInfo?["read"] as? Bool
                else {
                    return
                }
                unreadCount += read ? -1 : 1
            }
        Spacer()
        ToggleReadButtonView(unreadCount: $unreadCount, refreshing: $refreshing) {
            await SyncUtility.toggleReadUnread(container: container, items: trend.items)
        }
    }
}
