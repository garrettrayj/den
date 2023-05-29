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
        NavigationLink(value: DetailPanel.page(page)) {
            Label {
                if editMode?.wrappedValue.isEditing == true {
                    if let pageName = page.displayName {
                        Text(pageName)
                    } else {
                        Text("Untitled")
                    }
                } else {
                    WithItems(scopeObject: page, readFilter: false) { items in
                        if let pageName = page.displayName {
                            Text(pageName).badge(items.count)
                        } else {
                            Text("Untitled").badge(items.count)
                        }
                    }
                }
            } icon: {
                Image(systemName: page.wrappedSymbol)
            }
            .lineLimit(1)
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
