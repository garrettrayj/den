//
//  TagsSection.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct TagsSection: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    var body: some View {
        Section {
            ForEach(profile.tagsArray) { tag in
                SidebarTag(tag: tag)
            }
            .onMove(perform: moveTags)
        } header: {
            Text("Tags", comment: "Sidebar section header.")
        }
    }

    private func moveTags(from source: IndexSet, to destination: Int) {
        var revisedItems = profile.tagsArray

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update the userOrder attribute in revisedItems to persist the new order.
        // This is done in reverse order to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }

        do {
            try viewContext.save()
            profile.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
