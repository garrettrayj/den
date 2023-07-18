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
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif

    @ObservedObject var profile: Profile

    var body: some View {
        Section {
            ForEach(profile.pagesArray) { page in
                PageNavLink(profile: profile, page: page)
            }
            .onMove(perform: movePage)
            .onDelete(perform: deletePage)
        } header: {
            #if os(macOS)
            Text("Pages", comment: "Sidebar section header.")
            #else
            if editMode?.wrappedValue == .active {
                Label {
                    Text("New Page", comment: "Button label.")
                } icon: {
                    Image(systemName: "plus")
                }
                .onTapGesture {
                    withAnimation { addPage() }
                }
                .foregroundColor(.accentColor)
                .accessibilityIdentifier("NewPage")
            } else {
                Text("Pages", comment: "Sidebar section header.")
            }
            #endif
        }
    }

    private func movePage(from source: IndexSet, to destination: Int) {
        var revisedItems = profile.pagesArray

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

    private func deletePage(indices: IndexSet) {
        indices.forEach {
            let page = profile.pagesArray[$0]
            page.feedsArray.forEach { feed in
                if let feedData = feed.feedData {
                    viewContext.delete(feedData)
                }
            }
            viewContext.delete(page)
        }

        do {
            try viewContext.save()
            profile.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func addPage() {
        _ = Page.create(in: viewContext, profile: profile, prepend: true)

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
