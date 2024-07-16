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
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var newFeedPageObjectURL: URL?
    @Binding var newFeedWebAddress: String
    @Binding var showingNewFeedSheet: Bool
    
    let pages: FetchedResults<Page>

    var body: some View {
        Section {
            ForEach(pages) { page in
                SidebarPage(
                    page: page,
                    newFeedPageObjectURL: $newFeedPageObjectURL,
                    newFeedWebAddress: $newFeedWebAddress,
                    showingNewFeedSheet: $showingNewFeedSheet
                )
            }
            .onMove(perform: movePages)
            .onDelete(perform: deletePages)
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

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func deletePages(at offsets: IndexSet) {
        for index in offsets {
            let page = pages[index]
            page.feedsArray.compactMap { $0.feedData }.forEach { viewContext.delete($0) }
            viewContext.delete(page)
        }

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
