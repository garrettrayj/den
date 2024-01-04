//
//  InboxNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//

import CoreData
import SwiftUI

struct InboxNavLink: View {
    @ObservedObject var profile: Profile

    var body: some View {
        WithItems(scopeObject: profile, readFilter: false) { items in
            Label {
                Text("Inbox", comment: "Button label.").lineLimit(1).badge(items.count)
            } icon: {
                Image(systemName: items.count > 0 ? "tray.full" : "tray")
            }
        }
        .tag(DetailPanel.inbox)
        .accessibilityIdentifier("InboxNavLink")
    }
}
