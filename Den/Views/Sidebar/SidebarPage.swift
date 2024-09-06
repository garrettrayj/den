//
//  SidebarPage.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPage: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.showUnreadCounts) private var showUnreadCounts
    
    @ObservedObject var page: Page
    
    @State private var showingIconSelector = false
    
    @SceneStorage("ExpandedPages") var expandedPages: Set<UUID> = []
    @SceneStorage("NewFeedPageObjectURL") private var newFeedPageObjectURL: URL?
    @SceneStorage("NewFeedWebAddress") private var newFeedWebAddress: String = ""
    @SceneStorage("ShowingNewFeedSheet") private var showingNewFeedSheet: Bool = false
    
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
                SidebarFeed(feed: feed)
            }
            .onMove(perform: moveFeeds)
            .onDelete(perform: deleteFeeds)
        } label: {
            WithItemsUnreadCount(scopeObject: page) { unreadCount in
                Label {
                    #if os(macOS)
                    TextField(text: $page.wrappedName) {
                        page.displayName
                    }
                    .onSubmit {
                        if viewContext.hasChanges {
                            do {
                                try viewContext.save()
                            } catch {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        }
                    }
                    #else
                    page.displayName
                    #endif
                } icon: {
                    Image(systemName: page.wrappedSymbol)
                }
                .badge(showUnreadCounts ? unreadCount : 0)
                .contentShape(Rectangle())
                .onDrop(
                    of: [.denFeed, .url, .text],
                    delegate: PageNavDropDelegate(
                        context: viewContext,
                        page: page,
                        newFeedPageObjectURL: $newFeedPageObjectURL,
                        newFeedWebAddress: $newFeedWebAddress,
                        showingNewFeedSheet: $showingNewFeedSheet
                    )
                )
                .contextMenu {
                    IconSelectorButton(
                        showingIconSelector: $showingIconSelector,
                        symbol: $page.wrappedSymbol
                    )
                    DeletePageButton(page: page)
                }
                .sheet(
                    isPresented: $showingIconSelector,
                    onDismiss: {
                        if viewContext.hasChanges {
                            do {
                                try viewContext.save()
                            } catch {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        }
                    },
                    content: {
                        IconSelector(selection: $page.wrappedSymbol)
                    }
                )
                .contextMenu {
                    MarkAllReadUnreadButton(allRead: unreadCount == 0) {
                        HistoryUtility.changeRead(
                            context: viewContext,
                            newReadFlag: unreadCount > 0,
                            scopeObject: page
                        )
                    }
                    Divider()
                    IconSelectorButton(
                        showingIconSelector: $showingIconSelector,
                        symbol: $page.wrappedSymbol
                    )
                    DeletePageButton(page: page)
                }
                .accessibilityIdentifier("SidebarPage")
            }
        }
        .tag(DetailPanel.page(page.objectID.uriRepresentation()))
    }
    
    private func moveFeeds( from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Feed] = page.feedsArray.map { $0 }

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update the userOrder attribute in revisedItems to persist the new order.
        // This is done in reverse to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }

        do {
            try viewContext.save()
            page.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
    
    private func deleteFeeds(at offsets: IndexSet) {
        for index in offsets {
            let feed = page.feedsArray[index]
            if let feedData = feed.feedData {
                viewContext.delete(feedData)
            }
            viewContext.delete(feed)
        }

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
