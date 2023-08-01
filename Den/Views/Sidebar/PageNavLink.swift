//
//  PageNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct PageNavLink: View {
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page
    // Observe profile so badge cound updates after refresh
    @ObservedObject var profile: Profile

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
        .contextMenu {
            Button {
                page.feedsArray.forEach { feed in
                    if let feedData = feed.feedData {
                        viewContext.delete(feedData)
                    }
                }
                viewContext.delete(page)
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            } label: {
                Text("Delete", comment: "Button label.")
            }
        }
        .accessibilityIdentifier("PageNavLink")
    }
}
