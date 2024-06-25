//
//  SidebarPage.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SidebarPage: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var page: Page

    @Binding var newFeedPageID: String?
    @Binding var newFeedURLString: String
    @Binding var showingNewFeedSheet: Bool
    
    @State private var showingIconSelector = false
    
    @SceneStorage("ExpandedPages") var expandedPages: Set<UUID> = []
    
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    
    var isExpandedBinding: Binding<Bool> {
        Binding<Bool> {
            guard let id = page.id else { return false}

            return expandedPages.contains(id)
        }
        set: { isExpanded in
            guard let id = page.id else { return }
            
            if isExpanded {
                expandedPages.insert(id)
            } else {
                expandedPages.remove(id)
            }
        }
    }

    var body: some View {
        DisclosureGroup(isExpanded: isExpandedBinding) {
            ForEach(page.feedsArray, id: \.self) { feed in
                SidebarFeed(feed: feed, unreadCount: feed.feedData?.itemsArray.count ?? 0)
            }
            .onMove(perform: moveFeed)
        } label: {
            WithItems(scopeObject: page) { items in
                Label {
                    #if os(macOS)
                    TextField(text: $page.wrappedName) {
                        page.displayName
                    }
                    #else
                    page.displayName
                    #endif
                } icon: {
                    Image(systemName: page.wrappedSymbol)
                }
                .badge(showUnreadCounts ? items.unread.count : 0)
                .contentShape(Rectangle())
                .onDrop(
                    of: [.denFeed, .url, .text],
                    delegate: PageNavDropDelegate(
                        modelContext: modelContext,
                        page: page,
                        newFeedPageID: $newFeedPageID,
                        newFeedURLString: $newFeedURLString,
                        showingNewFeedSheet: $showingNewFeedSheet
                    )
                )
                .contextMenu {
                    MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                        HistoryUtility.toggleReadUnread(context: modelContext, items: items)
                    }
                    Divider()
                    IconSelectorButton(
                        showingIconSelector: $showingIconSelector,
                        symbol: $page.wrappedSymbol
                    )
                    DeletePageButton(page: page)
                }
                .sheet(
                    isPresented: $showingIconSelector,
                    content: {
                        IconSelector(selection: $page.wrappedSymbol)
                    }
                )
                .accessibilityIdentifier("SidebarPage")
            }
        }
        .tag(DetailPanel.page(page))
    }
    
    private func moveFeed( from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Feed] = page.feedsArray.map { $0 }

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update the userOrder attribute in revisedItems to persist the new order.
        // This is done in reverse to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
    }
}
