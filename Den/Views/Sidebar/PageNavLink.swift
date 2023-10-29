//
//  PageNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct PageNavLink: View {
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    @Binding var detailPanel: DetailPanel?
    @Binding var newFeedPageID: String?
    @Binding var newFeedWebAddress: String
    @Binding var showingNewFeedSheet: Bool

    var body: some View {
        Group {
            #if os(macOS)
            Button {
                detailPanel = .page(page)
            } label: {
                Label {
                    WithItems(scopeObject: page, readFilter: false) { items in
                        TextField(text: $page.wrappedName) { page.nameText }.badge(items.count)
                    }
                } icon: {
                    Image(systemName: page.wrappedSymbol)
                }
            }
            #else
            if editMode?.wrappedValue.isEditing == true {
                TextField(text: $page.wrappedName) { page.nameText }
            } else {
                Button {
                    detailPanel = .page(page)
                } label: {
                    Label {
                        WithItems(scopeObject: page, readFilter: false) { items in
                            page.nameText.badge(items.count)
                        }
                    } icon: {
                        Image(systemName: page.wrappedSymbol)
                    }
                }
            }
            #endif
        }
        .lineLimit(1)
        .tag(DetailPanel.page(page))
        .contentShape(Rectangle())
        .onDrop(
            of: [.denFeed, .url, .text],
            delegate: PageNavDropDelegate(
                context: viewContext,
                page: page,
                newFeedPageID: $newFeedPageID,
                newFeedWebAddress: $newFeedWebAddress,
                showingNewFeedSheet: $showingNewFeedSheet
            )
        )
        .accessibilityIdentifier("PageNavLink")
        .contextMenu {
            DeletePageButton(page: page)
        }
    }
}
