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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var crashManager: CrashManager

    @ObservedObject var viewModel: PageViewModel

    @State var showingIconPicker: Bool = false
    @State var showingDeleteAlert: Bool = false

    var body: some View {
        Form {
            nameIconSection

            if viewModel.page.feedsArray.count > 0 {
                feedsSection
            }
        }
        .navigationTitle("Page Settings")
        .environment(\.editMode, .constant(.active))
        .toolbar {
            ToolbarItem {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash").symbolRenderingMode(.multicolor)
                }
                .buttonStyle(NavigationBarButtonStyle())
                .alert(
                    "Delete \(viewModel.page.displayName)?",
                    isPresented: $showingDeleteAlert,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            deletePage()
                        }
                    },
                    message: {
                        Text("All feeds will be removed.")
                    }
                )
            }
        }
        .onDisappear(perform: save)
    }

    private var nameIconSection: some View {
        Section(header: Text("Name and Icon").modifier(SectionHeaderModifier())) {
            HStack {
                TextField("Untitled", text: $viewModel.page.wrappedName)
                    .modifier(TitleTextFieldModifier())
                HStack {
                    Image(systemName: viewModel.page.wrappedSymbol)
                        .foregroundColor(Color.accentColor)

                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                        .foregroundColor(.secondary)

                }
                .onTapGesture { showingIconPicker = true }
                .sheet(isPresented: $showingIconPicker) {
                    IconPickerView(page: viewModel.page)
                        .environment(\.colorScheme, colorScheme)
                }
            }.modifier(FormRowModifier())
        }
    }

    private var feedsSection: some View {
        Section(
            header: HStack {
                Text("\(viewModel.page.feedsArray.count) Feeds")
                Spacer()
                Text("Drag to Reorder")
            }.modifier(SectionHeaderModifier())
        ) {
            ForEach(viewModel.page.feedsArray) { feed in
                FeedTitleLabelView(
                    title: feed.wrappedTitle,
                    faviconImage: feed.feedData?.faviconImage
                ).padding(.vertical, 4)
            }
            .onDelete(perform: deleteFeed)
            .onMove(perform: moveFeed)
        }
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                viewModel.objectWillChange.send()
                viewModel.page.feedsArray.forEach { feed in
                    feed.objectWillChange.send()
                }
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }
    }

    private func deletePage() {
        viewContext.delete(viewModel.page)

        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .profileRefreshed, object: viewModel.page.profile?.objectID)
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    private func deleteFeed(indices: IndexSet) {
        indices.forEach { viewContext.delete(viewModel.page.feedsArray[$0]) }

        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .pageRefreshed, object: viewModel.page.objectID)
        } catch {
            crashManager.handleCriticalError(error as NSError)
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
