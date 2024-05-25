//
//  InboxNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct InboxNavLink: View {
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    
    var body: some View {
        WithItems { items in
            Label {
                Text("Inbox", comment: "Button label.")
            } icon: {
                Image(systemName: items.count > 0 ? "tray.full" : "tray")
            }
            .badge(showUnreadCounts ? items.unread.count : 0)
            .tag(DetailPanel.inbox)
            .accessibilityIdentifier("InboxNavLink")
            .contextMenu {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        }
    }
}
