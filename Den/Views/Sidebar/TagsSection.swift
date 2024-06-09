//
//  TagsSection.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TagsSection: View {
    @Environment(\.modelContext) private var modelContext

    let tags: [Tag]
    
    var body: some View {
        Section {
            ForEach(tags) { tag in
                SidebarTag(tag: tag)
            }
            .onMove(perform: moveTags)
        } header: {
            Text("Tags", comment: "Sidebar section header.")
        }
    }

    private func moveTags(from source: IndexSet, to destination: Int) {
        var revisedItems = Array(tags)

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update the userOrder attribute in revisedItems to persist the new order.
        // This is done in reverse order to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }

        do {
            try modelContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
