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
    
    var unreadCount: Int {
        trend.items.unread().count
    }

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) {
            trend.objectWillChange.send()
        }
        Spacer()
        Text("\(unreadCount) Unread")
            .font(.caption)
            .fixedSize()
        Spacer()
        ToggleReadButtonView(unreadCount: unreadCount) {
            await SyncUtility.toggleReadUnread(container: container, items: trend.items)
            trend.objectWillChange.send()
        }
    }
}
