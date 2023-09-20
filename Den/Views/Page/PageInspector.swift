//
//  PageInspector.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageInspector: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    @State private var showingIconPicker: Bool = false

    var body: some View {
        Form {
            generalSection
            feedsSection

            Section {
                DeletePageButton(page: page)
            } header: {
                Text("Danger Zone")
            }
        }
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        #endif
        .onDisappear {
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        }
    }

    private var generalSection: some View {
        Section {
            TextField(
                text: $page.wrappedName,
                prompt: Text("Untitled", comment: "Text field prompt.")
            ) {
                Label {
                    Text("Name", comment: "Text field label.")
                } icon: {
                    Image(systemName: "character.cursor.ibeam")
                }
            }

            IconSelectorButton(symbol: $page.wrappedSymbol)
        }
    }

    private var feedsSection: some View {
        Section {
            if page.feedsArray.isEmpty {
                Text("Page Empty", comment: "Page settings feeds empty message.")
                    .foregroundStyle(.secondary)

            } else {
                List {
                    ForEach(page.feedsArray) { feed in
                        HStack {
                            FeedTitleLabel(
                                title: feed.titleText,
                                favicon: feed.feedData?.favicon
                            )
                            Spacer()
                            #if os(macOS)
                            Image(systemName: "line.3.horizontal")
                                .imageScale(.large)
                                .foregroundStyle(.tertiary)
                            #endif
                        }.padding(.vertical, 4)
                    }
                    .onMove(perform: moveFeed)
                }
            }
        } header: {
            Text("Feeds", comment: "Page settings section header.")
        }
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

        page.objectWillChange.send()
    }
}
