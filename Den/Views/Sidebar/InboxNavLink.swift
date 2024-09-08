//
//  InboxNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct InboxNavLink: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.showUnreadCounts) private var showUnreadCounts
    
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
                    HistoryUtility.toggleRead(items: items, context: viewContext)
                }
            }
        }
    }
}
