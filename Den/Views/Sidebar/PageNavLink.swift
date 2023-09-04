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
import UniformTypeIdentifiers

struct PageNavLink: View {
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    @Binding var newFeedPageID: String?
    @Binding var newFeedWebAddress: String
    @Binding var showingNewFeedSheet: Bool

    var body: some View {
        Label {
            #if os(macOS)
            WithItems(scopeObject: page, readFilter: false) { items in
                TextField(text: $page.wrappedName) { page.nameText }.badge(items.count)
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
        .tag(DetailPanel.page(page))
        .contentShape(Rectangle())
        .onDrop(
            of: [.feed, .url, .text],
            delegate: FeedDropDelegate(
                context: viewContext,
                page: page,
                newFeedPageID: $newFeedPageID,
                newFeedWebAddress: $newFeedWebAddress,
                showingNewFeedSheet: $showingNewFeedSheet
            )
        )
        .accessibilityIdentifier("PageNavLink")
    }
}
