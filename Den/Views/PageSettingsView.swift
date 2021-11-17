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
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var crashManager: CrashManager

    @ObservedObject var page: Page

    @State var showingIconPicker: Bool = false
    @State var showingDeleteAlert: Bool = false

    @State var itemsPerFeedStepperValue: Int = 0

    var body: some View {
        Form {
            nameIconSection
            configurationSection

            if page.feedsArray.count > 0 {
                feedsSection
            }
        }
        .navigationTitle("Page Settings")
        .environment(\.editMode, .constant(.active))
        .toolbar { toolbar }
        .onDisappear(perform: save)
        .onReceive(
            NotificationCenter.default.publisher(for: .pageDeleted, object: page.objectID)
        ) { _ in
            dismiss()
        }
    }

    private var nameIconSection: some View {
        Section(header: Text("Name and Icon").modifier(SectionHeaderModifier())) {
            HStack {
                TextField("Untitled", text: $page.wrappedName).lineLimit(1)
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
            }.modifier(FormRowModifier())
        }
    }

    private var configurationSection: some View {
        Section(header: Text("Configuration").modifier(SectionHeaderModifier())) {
            Stepper(value: $page.wrappedItemsPerFeed, in: 1...Int(Int16.max), step: 1) {
                Label(
                    "Item Limit: \(page.wrappedItemsPerFeed)",
                    systemImage: "list.bullet.rectangle"
                )
            }.modifier(FormRowModifier())
        }
    }

    private var feedsSection: some View {
        Section(
            header: HStack {
                Text("\(page.feedsArray.count) Feeds")
                Spacer()
                Text("Drag to Reorder")
            }.modifier(SectionHeaderModifier())
        ) {
            ForEach(page.feedsArray) { feed in
                FeedTitleLabelView(feed: feed).padding(.vertical, 4)
            }
            .onDelete(perform: deleteFeed)
            .onMove(perform: moveFeed)
        }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup {
            HStack(spacing: 0) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash").symbolRenderingMode(.multicolor)
                }
                .alert("Remove \(page.displayName)?", isPresented: $showingDeleteAlert, actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        deletePage()
                    }
                })
            }
        }
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                page.feedsArray.forEach { feed in
                    feed.objectWillChange.send()
                }
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }
    }

    private func deletePage() {
        NotificationCenter.default.post(name: .pageDeleted, object: page.objectID)
        viewContext.delete(page)

        do {
            try viewContext.save()
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    private func deleteFeed(indices: IndexSet) {
        indices.forEach { viewContext.delete(page.feedsArray[$0]) }

        do {
            try viewContext.save()
        } catch {
            crashManager.handleCriticalError(error as NSError)
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
