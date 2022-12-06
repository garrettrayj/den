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
    
    var unreadCount: Int {
        profile.previewItems.unread().count
    }

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) {
            profile.objectWillChange.send()
        }
        Spacer()
        Text("\(unreadCount) Unread")
            .font(.caption)
            .fixedSize()
        Spacer()
        ToggleReadButtonView(unreadCount: unreadCount) {
            await SyncUtility.toggleReadUnread(container: container, items: profile.previewItems)
            profile.objectWillChange.send()
            for page in profile.pagesArray {
                page.objectWillChange.send()
            }
        }
    }
}

