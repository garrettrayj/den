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

    @Binding var detailPanel: DetailPanel?

    var body: some View {
        Button {
            detailPanel = .inbox
        } label: {
            Label {
                WithItems(scopeObject: profile, readFilter: false) { items in
                    Text("Inbox", comment: "Button label.")
                        .lineLimit(1)
                        .badge(items.count)
                }
            } icon: {
                Image(systemName: "tray")
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("InboxNavLink")
        .tag(DetailPanel.inbox)
    }
}
