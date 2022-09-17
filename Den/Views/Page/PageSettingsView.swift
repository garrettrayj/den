//
//  PageSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    var body: some View {
        Form {
            nameIconSection
            feedsSection
        }
        .navigationTitle("Page Settings")
        .environment(\.editMode, .constant(.active))
        .onDisappear(perform: save)
    }

    private var nameIconSection: some View {
        Section(header: Text("\nName & Icon")) {
            HStack {
                TextField("Untitled", text: $page.wrappedName)
                    .modifier(TitleTextFieldModifier())

            }.modifier(FormRowModifier())

            NavigationLink(value: DetailPanel.iconPicker(page)) {
                Label {
                    HStack {
                        Text("Select Icon")
                        Spacer()
                        Image(systemName: page.wrappedSymbol).foregroundColor(Color.accentColor)
                    }

                } icon: {
                    Image(systemName: "square.grid.3x3.topleft.filled")
                }
            }.modifier(FormRowModifier())
        }
    }

    private var feedsSection: some View {
        Section(header: Text("Feeds")) {
            if page.feedsArray.isEmpty {
                Label("Page empty", systemImage: "questionmark.folder")
                    .foregroundColor(.secondary)
                    .modifier(FormRowModifier())
            } else {
                ForEach(page.feedsArray) { feed in
                    FeedTitleLabelView(title: feed.wrappedTitle, favicon: feed.feedData?.favicon)
                }
                .modifier(FormRowModifier())
                .onDelete(perform: deleteFeed)
                .onMove(perform: moveFeed)
            }
        }
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                page.objectWillChange.send()
            } catch {
                CrashManager.handleCriticalError(error as NSError)
            }
        }
    }

    private func deleteFeed(indices: IndexSet) {
        indices.forEach { viewContext.delete(page.feedsArray[$0]) }

        do {
            try viewContext.save()
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }
    }

    private func moveFeed( from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Feed] = page.feedsArray.map { $0 }

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
    }
}
