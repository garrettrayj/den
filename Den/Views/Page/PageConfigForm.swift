//
//  PageConfigForm.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageConfigForm: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    @State private var showingIconPicker: Bool = false

    var body: some View {
        Form {
            generalSection
            feedsSection
        }
        .formStyle(.grouped)
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
            .lineLimit(1)

            Button {
                showingIconPicker = true
            } label: {
                Label {
                    HStack {
                        Text("Choose Icon", comment: "Button label.")
                        Spacer()
                        ButtonChevron()
                    }
                } icon: {
                    Image(systemName: page.wrappedSymbol)
                }
            }
            .buttonStyle(.borderless)
            .navigationDestination(isPresented: $showingIconPicker) {
                IconPicker(symbolID: $page.wrappedSymbol)
            }

            Button(role: .destructive) {
                viewContext.delete(page)
            } label: {
                Label {
                    Text("Delete Page", comment: "Button label.")
                } icon: {
                    Image(systemName: "folder.badge.minus")
                }
                .symbolRenderingMode(.multicolor)
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("DeletePage")
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
                            FeedTitleLabel(feed: feed)
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
                #if os(iOS)
                .environment(\.editMode, .constant(.active))
                #endif
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
