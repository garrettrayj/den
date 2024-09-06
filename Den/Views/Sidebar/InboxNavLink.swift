//
//  InboxNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct InboxNavLink: View {
    @Environment(\.showUnreadCounts) private var showUnreadCounts
    
    var body: some View {
        WithItemsUnreadCount { unreadCount in
            Label {
                Text("Inbox", comment: "Button label.")
            } icon: {
                Image(systemName: unreadCount > 0 ? "tray.full" : "tray")
            }
            .badge(showUnreadCounts ? unreadCount : 0)
            .tag(DetailPanel.inbox)
            .accessibilityIdentifier("InboxNavLink")
        }
    }
}
