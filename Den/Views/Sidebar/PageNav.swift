//
//  PageNav.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct PageNav: View {
    @Environment(\.editMode) private var editMode

    @ObservedObject var page: Page

    var body: some View {
        NavigationLink(value: ContentPanel.page(page)) {
            Label {
                if editMode?.wrappedValue.isEditing == true {
                    Text(page.displayName).lineLimit(1)
                } else {
                    WithItems(scopeObject: page, readFilter: false) { items in
                        Text(page.displayName).lineLimit(1).badge(items.count)
                    }
                }
            } icon: {
                Image(systemName: page.wrappedSymbol)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed, object: nil)) { notification in
            if page.objectID == notification.userInfo?["pageObjectID"] as? NSManagedObjectID {
                page.objectWillChange.send()
            }
        }
        .modifier(URLDropTargetModifier(page: page))
        .accessibilityIdentifier("page-button")
    }
}
