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
import UserNotifications

struct InboxNavView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    let searchModel: SearchModel

    @Binding var contentSelection: ContentPanel?

    @State private var searchInput = ""

    var body: some View {
        WithItems(scopeObject: profile, readFilter: false) { _, items in
            Label {
                Text("Inbox").lineLimit(1).badge(items.count)
            } icon: {
                Image(systemName: "tray")
            }
            .onChange(of: items.count) { newValue in
                updateIconBadge(count: newValue)
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
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    UIApplication.shared.applicationIconBadgeNumber = items.count
                default: break
                }
            }
            .disabled(editMode?.wrappedValue == .active)
            .accessibilityIdentifier("inbox-button")
            .tag(ContentPanel.inbox)
        }
    }

    private func updateIconBadge(count: Int) {
        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (_, error) in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = count
                }
            }
        }
    }
}
