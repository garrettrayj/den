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
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var profile: Profile

    var body: some View {
        Label {
            WithItems(scopeObject: profile, readFilter: false) { items in
                Text("Inbox", comment: "Button label.")
                    .lineLimit(1)
                    .badge(items.count)
            }
        } icon: {
            Image(systemName: "tray")
        }
        .tag(DetailPanel.inbox)
        .accessibilityIdentifier("InboxNavLink")
    }
}
