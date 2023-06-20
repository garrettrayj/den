//
//  PageSettingsForm.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageSettingsForm: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    @State private var showIconPicker: Bool = false

    var body: some View {
        Form {
            generalSection
            feedsSection
        }
        .formStyle(.grouped)
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(Text("Page Settings", comment: "Navigation title."))
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

            Button {
                showIconPicker = true
            } label: {
                Label {
                    Text("Choose Icon", comment: "Button label.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                } icon: {
                    Image(systemName: page.wrappedSymbol)
                }
            }
            .buttonStyle(.borderless)
            .navigationDestination(isPresented: $showIconPicker) {
                IconPicker(symbolID: $page.wrappedSymbol)
            }
        }
    }

    private var feedsSection: some View {
        Section {
            if page.feedsArray.isEmpty {
                Text("Page Empty", comment: "Page settings feeds empty message.")
                    .foregroundColor(.secondary)

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
                    .onDelete(perform: deleteFeed)
                    .onMove(perform: moveFeed)
                }
            }
        } header: {
            Text("Feeds", comment: "Page settings section header.")
        }
    }

    private func deleteFeed(indices: IndexSet) {
        indices.forEach {
            let feed = page.feedsArray[$0]
            if let feedData = feed.feedData {
                viewContext.delete(feedData)
            }
            viewContext.delete(page.feedsArray[$0])
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

        do {
            try viewContext.save()
            page.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
