//
//  PageNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct PageNavLink: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    @Binding var newFeedPageID: String?
    @Binding var newFeedWebAddress: String
    @Binding var showingNewFeedSheet: Bool
    
    @State private var showingIconSelector = false

    var body: some View {
        DisclosureGroup {
            ForEach(page.feedsArray, id: \.self) { feed in
                Label {
                    feed.titleText
                } icon: {
                    #if os(macOS)
                    FaviconImage(url: feed.feedData?.favicon, size: .small)
                    #else
                    FaviconImage(url: feed.feedData?.favicon, size: .large)
                    #endif
                }
                .tag(DetailPanel.feed(feed))
            }
            .onMove(perform: moveFeed)
        } label: {
            Label {
                WithItems(scopeObject: page, readFilter: false) { items in
                    #if os(macOS)
                    TextField(text: $page.wrappedName) { page.nameText }.badge(items.count)
                    #else
                    page.nameText.badge(items.count)
                    #endif
                }
            } icon: {
                Image(systemName: page.wrappedSymbol)
            }
            .accessibilityIdentifier("PageNavLink")
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
                    IconSelector(symbol: $page.wrappedSymbol)
                }
            )
        }
        .tag(DetailPanel.page(page))
        .lineLimit(1)
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

        do {
            try viewContext.save()
            page.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
