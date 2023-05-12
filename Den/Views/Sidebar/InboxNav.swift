//
//  InboxNav.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct InboxNav: View {
    @ObservedObject var profile: Profile

    var body: some View {
        NavigationLink(value: DetailPanel.inbox) {
            WithItems(scopeObject: profile, readFilter: false) { items in
                Label {
                    Text("Inbox").lineLimit(1).badge(items.count)
                } icon: {
                    Image(systemName: items.isEmpty ? "tray" : "tray.full")
                }
            }
        }
        .accessibilityIdentifier("inbox-button")
        #if !targetEnvironment(macCatalyst)
        .modifier(ListRowModifier())
        #endif
    }
}
