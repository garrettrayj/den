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
    var body: some View {
        WithItems(readFilter: false) { items in
            Label {
                Text("Inbox", comment: "Button label.").lineLimit(1)
            } icon: {
                Image(systemName: items.count > 0 ? "tray.full" : "tray")
            }
        }
        .tag(DetailPanel.inbox)
        .accessibilityIdentifier("InboxNavLink")
    }
}
