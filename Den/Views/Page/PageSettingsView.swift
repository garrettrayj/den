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
    @EnvironmentObject private var crashManager: CrashManager

    @ObservedObject var page: Page

    @State private var showingIconPicker: Bool = false

    var body: some View {
        Form {
            nameIconSection
            feedsSection
        }
        .navigationTitle("Page Settings")
        .environment(\.editMode, .constant(.active))
        .onDisappear(perform: save)
        .background(
            NavigationLink(isActive: $showingIconPicker, destination: {
                IconPickerView(selectedSymbol: $page.wrappedSymbol)
            }, label: {
                EmptyView()
            })
        )
        .modifier(BackNavigationModifier(title: page.displayName))
    }

    private var nameIconSection: some View {
        Section(header: Text("Name")) {
            HStack {
                TextField("Untitled", text: $page.wrappedName)
                    .modifier(TitleTextFieldModifier())

                HStack {
                    Image(systemName: page.wrappedSymbol)
                        .imageScale(.medium)
                        .foregroundColor(Color.accentColor)

                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                        .foregroundColor(.secondary)

                }
                .onTapGesture { showingIconPicker = true }
            }.modifier(FormRowModifier())
        }.modifier(SectionHeaderModifier())
    }

    private var feedsSection: some View {
        Section(header: Text("Feeds")) {
            if page.feedsArray.isEmpty {
                Text("Page Empty").foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            } else {
                ForEach(page.feedsArray) { feed in
                    FeedTitleLabelView(
                        title: feed.wrappedTitle,
                        favicon: feed.feedData?.favicon
                    ).padding(.vertical, 4)
                }
                .onDelete(perform: deleteFeed)
                .onMove(perform: moveFeed)
            }
        }.modifier(SectionHeaderModifier())
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                NotificationCenter.default.post(name: .pageRefreshed, object: page.objectID)
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }
    }

    func deleteFeed(indices: IndexSet) {
        indices.forEach { viewContext.delete(page.feedsArray[$0]) }

        do {
            try viewContext.save()
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    func moveFeed( from source: IndexSet, to destination: Int) {
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
