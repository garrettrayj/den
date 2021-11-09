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

    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        Form {
            Section(header: Text("Name and Icon")) {
                HStack {
                    TextField("Untitled", text: $viewModel.page.wrappedName).lineLimit(1).padding(.vertical, 4)
                    HStack {
                        Image(systemName: viewModel.page.wrappedSymbol)
                            .foregroundColor(Color.accentColor)

                        Image(systemName: "chevron.down")
                            .imageScale(.small)
                            .foregroundColor(.secondary)

                    }
                    .onTapGesture { viewModel.showingIconPicker = true }
                    .sheet(isPresented: $viewModel.showingIconPicker) {
                        IconPickerView(activeIcon: $viewModel.page.wrappedSymbol)
                    }
                }
            }
            Section(header: Text("Settings")) {
                Stepper(value: $viewModel.page.wrappedItemsPerFeed, in: 1...Int(Int16.max), step: 1) { _ in
                    viewModel.refreshAfterSave = true
                } label: {
                    Label(
                        "Gadget Item Limit: \(viewModel.page.wrappedItemsPerFeed)",
                        systemImage: "list.bullet.rectangle"
                    )
                }
            }

            if viewModel.page.feedsArray.count > 0 {
                feedsSection
            }
        }
        .navigationTitle("Page Settings")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
        .onDisappear(perform: save)
    }

    private var feedsSection: some View {
        Section(
            header: HStack {
                Text("\(viewModel.page.feedsArray.count) Feeds")
                Spacer()
                Text("Drag to Reorder")
            }
        ) {
            ForEach(viewModel.page.feedsArray) { feed in
                FeedTitleLabelView(feed: feed).padding(.vertical, 4)
            }
            .onDelete(perform: deleteFeed)
            .onMove(perform: moveFeed)
        }
    }

    private func close() {
        presentationMode.wrappedValue.dismiss()
    }

    private func save() {
        viewModel.page.objectWillChange.send()
        viewModel.page.feedsArray.forEach({ feed in
            feed.objectWillChange.send()
        })

        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                viewModel.contentViewModel.handleCriticalError(error as NSError)
            }

            if viewModel.refreshAfterSave {
                viewModel.refresh()
            }
        }
    }

    private func deleteFeed(indices: IndexSet) {
        indices.forEach { viewContext.delete(viewModel.page.feedsArray[$0]) }

        do {
            try viewContext.save()
        } catch {
            viewModel.contentViewModel.handleCriticalError(error as NSError)
        }
    }

    private func moveFeed( from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Feed] = viewModel.page.feedsArray.map { $0 }

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
