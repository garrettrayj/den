//
//  InboxNavView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct InboxNavView: View {
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    let searchModel: SearchModel

    @Binding var selection: Panel?

    @State private var searchInput = ""

    var body: some View {
        if editMode?.wrappedValue == .inactive {
            Label {
                Text("Inbox").lineLimit(1).badge(profile.previewItems.unread().count)
            } icon: {
                Image(systemName: profile.previewItems.unread().count > 0 ? "tray.full": "tray")
            }
            .searchable(
                text: $searchInput,
                placement: .navigationBarDrawer(displayMode: .automatic)
            )
            .onSubmit(of: .search) {
                searchModel.query = searchInput
                selection = .search
            }
            .accessibilityIdentifier("inbox-button")
            .tag(Panel.inbox)
        }
    }
}
