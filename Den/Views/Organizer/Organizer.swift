//
//  Organizer.swift
//  Den
//
//  Created by Garrett Johnson on 9/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct Organizer: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selection = Set<Feed>()
    
    #if os(macOS)
    @SceneStorage("ShowingOrganizerInspector") private var showingInspector = true
    #else
    @SceneStorage("ShowingOrganizerInspector") private var showingInspector = false
    #endif
    
    @Query(sort: [
        SortDescriptor(\Page.userOrder, order: .forward),
        SortDescriptor(\Page.name, order: .forward)
    ])
    private var pages: [Page]

    var body: some View {
        Group {
            if pages.feeds.count == 0 {
                ContentUnavailable {
                    Label {
                        Text("No Feeds", comment: "Content unavailable title.")
                    } icon: {
                        Image(systemName: "folder.badge.gearshape")
                    }
                }
            } else {
                List(selection: $selection) {
                    ForEach(pages) { page in
                        Section {
                            ForEach(page.feedsArray) { feed in
                                OrganizerRow(feed: feed)
                            }
                            .onMove { indices, newOffset in
                                moveFeeds(page: page, indices: indices, newOffset: newOffset)
                            }
                        } header: {
                            Label {
                                page.displayName
                            } icon: {
                                Image(systemName: page.wrappedSymbol)
                            }
                        }
                    }
                }
                .accessibilityIdentifier("OrganizerList")
                #if os(macOS)
                .listStyle(.inset(alternatesRowBackgrounds: true))
                #else
                .environment(\.editMode, .constant(.active))
                #endif
            }
        }
        .navigationTitle(Text("Organizer", comment: "Navigation title."))
        .inspector(isPresented: $showingInspector) {
            OrganizerInspector(selection: $selection, pages: pages)
        }
        .toolbar {
            OrganizerToolbar(
                selection: $selection,
                showingInspector: $showingInspector, 
                pages: pages
            )
        }
    }

    private func moveFeeds(page: Page, indices: IndexSet, newOffset: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Feed] = page.feedsArray.map { $0 }

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: indices, toOffset: newOffset)

        // Update the userOrder attribute in revisedItems to persist the new order.
        // This is done in reverse to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
    }
}
