//
//  PageSettings.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageSettings: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    @State private var showingIconPicker: Bool = false

    var body: some View {
        if page.managedObjectContext == nil {
            SplashNote(title: Text("Page Deleted"), symbol: "slash.circle")
        } else {
            Form {
                nameSection
                iconSection
                feedsSection
            }
            .environment(\.editMode, .constant(.active))
            .background(GroupedBackground())
            .navigationTitle(Text("Page Settings"))
            .onDisappear(perform: save)
        }
    }

    private var nameSection: some View {
        Section(header: Text("Name").modifier(FirstFormHeaderModifier())) {
            TextField("Untitled", text: $page.wrappedName)
                .modifier(FormRowModifier())
                .modifier(TitleTextFieldModifier())
        }
        .sheet(isPresented: $showingIconPicker) {
            NavigationStack {
                IconPicker(page: page)
            }
        }
        .modifier(ListRowModifier())
    }

    private var iconSection: some View {
        Section(header: Text("Icon")) {
            Button {
                showingIconPicker = true
            } label: {
                Label {
                    HStack {
                        Text("Choose Icon…")
                        Spacer()
                        Image(systemName: "chevron.down").foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: page.wrappedSymbol)
                }
            }
            .buttonStyle(.borderless)
            .modifier(FormRowModifier())
        }
        .sheet(isPresented: $showingIconPicker) {
            NavigationStack {
                IconPicker(page: page)
            }
        }
        .modifier(ListRowModifier())
    }

    private var feedsSection: some View {
        Section(header: Text("Feeds")) {
            if page.feedsArray.isEmpty {
                Text("Page Emtpy")
                    .foregroundColor(.secondary)
                    .modifier(FormRowModifier())
            } else {
                ForEach(page.feedsArray) { feed in
                    FeedTitleLabel(
                        title: feed.wrappedTitle,
                        favicon: feed.feedData?.favicon
                    ).modifier(FormRowModifier())
                }
                .onDelete(perform: deleteFeed)
                .onMove(perform: moveFeed)
            }
        }
        .modifier(ListRowModifier())
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                page.objectWillChange.send()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
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

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
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
    }
}
