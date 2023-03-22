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
import UserNotifications

struct InboxNav: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    let searchModel: SearchModel

    @Binding var contentSelection: ContentPanel?

    @State private var searchInput = ""

    var body: some View {
        NavigationLink(value: ContentPanel.inbox) {
            Label {
                WithItems(scopeObject: profile, readFilter: false) { items in
                    Text("Inbox").lineLimit(1).badge(items.count)
                }
            } icon: {
                Image(systemName: "tray")
            }
            .foregroundColor(editMode?.wrappedValue.isEditing == true ? Color(.secondaryLabel) : nil)
            .searchable(
                text: $searchInput,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .onSubmit(of: .search) {
                searchModel.query = searchInput
                contentSelection = .search
            }
            .disabled(editMode?.wrappedValue == .active)
            .accessibilityIdentifier("inbox-button")
            .tag(ContentPanel.inbox)
        }

    }
}
