//
//  PagesSection.swift
//  Den
//
//  Created by Garrett Johnson on 4/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PagesSection: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var newFeedPageID: String?
    @Binding var newFeedURLString: String
    @Binding var showingNewFeedSheet: Bool
    
    let pages: [Page]

    var body: some View {
        Section {
            ForEach(pages) { page in
                SidebarPage(
                    page: page,
                    newFeedPageID: $newFeedPageID,
                    newFeedURLString: $newFeedURLString,
                    showingNewFeedSheet: $showingNewFeedSheet
                )
            }
            .onMove(perform: movePages)
        } header: {
            Text("Folders", comment: "Sidebar section header.")
        }
    }

    private func movePages(from source: IndexSet, to destination: Int) {
        var revisedItems = Array(pages)

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update the userOrder attribute in revisedItems to persist the new order.
        // This is done in reverse order to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
    }
}
