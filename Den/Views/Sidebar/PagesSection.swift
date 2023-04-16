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
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    var body: some View {
        Section {
            ForEach(profile.pagesArray) { page in
                PageNav(page: page)
            }
            .onMove(perform: movePage)
            .onDelete(perform: deletePage)
        } header: {
            if editMode?.wrappedValue == .active {
                Text("\(Image(systemName: "plus")) New Page").onTapGesture {
                    withAnimation { addPage() }
                }
                .foregroundColor(.accentColor)
                .accessibilityIdentifier("new-page-button")
            } else {
                Text("Pages")
            }
        }
        #if !targetEnvironment(macCatalyst)
        .modifier(ListRowModifier())
        #endif
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
            viewContext.delete(profile.pagesArray[$0])
        }

        do {
            try viewContext.save()
            profile.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func addPage() {
        var pageName = "Untitled"
        var suffix = 2
        while profile.pagesArray.contains(where: { $0.name == pageName }) {
            pageName = "Untitled \(suffix)"
            suffix += 1
        }

        let newPage = Page.create(in: viewContext, profile: profile, prepend: true)
        newPage.wrappedName = pageName

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
