//
//  PageSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageSettingsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager

    @ObservedObject var page: Page

    @State private var itemsPerFeedStepperValue: Int = 0
    @State private var showingIconPicker: Bool = false

    var body: some View {
        Form {
            Section(header: Text("Name and Icon")) {

                HStack {
                    TextField("Untitled", text: $page.wrappedName).lineLimit(1).padding(.vertical, 4)

                    HStack {
                        Image(systemName: page.wrappedSymbol)
                            .foregroundColor(Color.accentColor)

                        Image(systemName: "chevron.down")
                            .imageScale(.small)
                            .foregroundColor(.secondary)

                    }
                    .onTapGesture { showingIconPicker = true }
                    .sheet(isPresented: $showingIconPicker) {
                        IconPickerView(activeIcon: $page.wrappedSymbol)
                    }

                }
            }
            Section(header: Text("Settings")) {
                Stepper(value: $itemsPerFeedStepperValue, in: 1...Int(Int16.max), step: 1) { _ in
                    page.wrappedItemsPerFeed = itemsPerFeedStepperValue
                } label: {
                    Label("Widget Item Limit: \(itemsPerFeedStepperValue)", systemImage: "list.bullet.rectangle")
                }
            }

            feedsSection
        }
        .navigationTitle("Page Settings")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
        .onAppear(perform: load)
        .onDisappear(perform: save)
    }

    private var feedsSection: some View {
        Section(
            header: HStack {
                Text("\(page.feedsArray.count) Feeds")
                Spacer()
                Text("Drag to Reorder")
            }
        ) {
            ForEach(page.feedsArray) { feed in
                FeedTitleLabelView(feed: feed).padding(.vertical, 4)
            }
            .onDelete(perform: deleteFeed)
            .onMove(perform: moveFeed)
        }
    }

    private func close() {
        presentationMode.wrappedValue.dismiss()
    }

    private func load() {
        itemsPerFeedStepperValue = page.wrappedItemsPerFeed
    }

    private func save() {
        page.objectWillChange.send()
        page.feedsArray.forEach({ feed in
            feed.objectWillChange.send()
        })

        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }
    }

    private func deleteFeed(indices: IndexSet) {
        page.feedsArray.delete(at: indices, from: viewContext)
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
