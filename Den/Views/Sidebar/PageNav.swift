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
    @Environment(\.managedObjectContext) private var viewContext
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif

    @ObservedObject var page: Page

    var body: some View {
        NavigationLink(value: DetailPanel.page(page)) {
            Label {
                #if os(macOS)
                WithItems(scopeObject: page, readFilter: false) { items in
                    page.nameText.badge(items.count)
                }
                #else
                if editMode?.wrappedValue.isEditing == true {
                    page.nameText
                } else {
                    WithItems(scopeObject: page, readFilter: false) { items in
                        page.nameText.badge(items.count)
                    }
                }
                #endif
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
        .contextMenu {
            Button {
                viewContext.delete(page)
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            } label: {
                Text("Delete", comment: "Context menu button label.")
            }
        }
        .accessibilityIdentifier("page-button")
    }
}
