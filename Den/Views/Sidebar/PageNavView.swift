//
//  PageNavView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct PageNavView: View {
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile
    @ObservedObject var page: Page

    var body: some View {
        if editMode?.wrappedValue == .inactive {
            Label {
                Text(page.displayName).lineLimit(1).badge(page.previewItems.unread().count)
            } icon: {
                Image(systemName: page.wrappedSymbol)
            }
            .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed, object: nil)) { notification in
                if page.objectID == notification.userInfo?["pageObjectID"] as? NSManagedObjectID {
                    page.objectWillChange.send()
                }
            }
            .modifier(URLDropTargetModifier(page: page))
            .accessibilityIdentifier("page-button")
            .tag(ContentPanel.page(page))
        } else {
            Label {
                Text(page.displayName).lineLimit(1)
            } icon: {
                Image(systemName: page.wrappedSymbol)
            }
        }
    }
}
