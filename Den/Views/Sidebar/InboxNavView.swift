//
//  InboxNavView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct InboxNavView: View {
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    let searchModel: SearchModel

    @Binding var contentSelection: ContentPanel?

    @State private var searchInput = ""

    var body: some View {
        Label {
            Text("Inbox").lineLimit(1).badge(profile.previewItems.unread().count)
        } icon: {
            Image(systemName: profile.previewItems.unread().count > 0 ? "tray.full": "tray")
        }
        .foregroundColor(editMode?.wrappedValue.isEditing == true ? .secondary : nil)
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
