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
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var profile: Profile
    
    @Binding var detailPanel: DetailPanel?

    var body: some View {
        Button {
            detailPanel = .inbox
        } label: {
            WithItems(scopeObject: profile, readFilter: false) { items in
                Label {
                    Text("Inbox", comment: "Button label.")
                        .lineLimit(1)
                        .badge(items.count)
                } icon: {
                    if items.count > 0 {
                        Image(systemName: "tray.full")
                    } else {
                        Image(systemName: "tray")
                    }
                }
            }
        }
        .tag(DetailPanel.inbox)
        .accessibilityIdentifier("InboxNavLink")
    }
}
