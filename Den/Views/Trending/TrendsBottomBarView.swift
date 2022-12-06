//
//  TrendsBottomBarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct TrendsBottomBarView: View {
    @Environment(\.persistentContainer) private var container
    
    @ObservedObject var profile: Profile
    
    @Binding var hideRead: Bool
    
    var unreadCount: Int {
        profile.trends.unread().count
    }

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) {
            profile.objectWillChange.send()
        }
        Spacer()
        Text("\(unreadCount) with Unread")
            .font(.caption)
            .fixedSize()
        Spacer()
        ToggleReadButtonView(unreadCount: unreadCount) {
            await SyncUtility.toggleReadUnread(container: container, items: profile.previewItems)
        }
    }
}
