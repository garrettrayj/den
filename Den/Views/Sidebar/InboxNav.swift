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
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    @Binding var contentSelection: ContentPanel?
    @Binding var searchQuery: String

    @State private var searchInput: String = ""

    var body: some View {
        NavigationLink(value: ContentPanel.inbox) {
            Label {
                WithItems(scopeObject: profile, readFilter: false) { items in
                    Text("Inbox").lineLimit(1).badge(items.count)
                }
            } icon: {
                Image(systemName: "tray")
            }
            .foregroundColor(editMode?.wrappedValue.isEditing == true ? .secondary : nil)
            .searchable(
                text: $searchInput,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .onSubmit(of: .search) {
                searchQuery = searchInput
                contentSelection = .search
            }
            .disabled(editMode?.wrappedValue == .active)
        }
        .accessibilityIdentifier("inbox-button")
        #if !targetEnvironment(macCatalyst)
        .modifier(ListRowModifier())
        #endif
    }
}
