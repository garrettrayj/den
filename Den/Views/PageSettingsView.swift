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

    let icons: [String] = [
        "scribble.variable",
        "highlighter",
        "pencil.and.outline",
        "lasso.sparkles",
        "paperplane",
        "folder",
        "questionmark.folder",
        "archivebox",
        "doc.richtext",
        "terminal",
        "doc.text.magnifyingglass",
        "calendar",
        "book",
        "newspaper",
        "books.vertical",
        "bookmark",
        "greetingcard",
        "rosette",
        "graduationcap",
        "ticket",
        "paperclip",
        "person",
        "person.and.arrow.left.and.arrow.right",
        "person.2",
        "person.3",
        "rectangle.stack.person.crop",
        "escape",
        "wake",
        "sleep",
        "globe",
        "network",
        "dot.arrowtriangles.up.right.down.left.circle",
        "sun.max",
        "sunrise",
        "sunset",
        "moon",
        "zzz",
        "moon.zzz",
        "sparkle",
        "sparkles",
        "moon.stars",
        "cloud",
        "cloud.rain",
        "cloud.sun",
        "smoke",
        "tornado",
        "snow",
        "tropicalstorm",
        "thermometer",
        "umbrella",
        "flame",
        "cursorarrow.rays"
    ]

    var body: some View {
        VStack {
            form
        }
        .navigationTitle("Page Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    var form: some View {
        Form {
            Section(header: Text("Name & Icon")) {
                HStack {
                    TextField("Untitled", text: $page.wrappedName).lineLimit(1).padding(.vertical, 4)

                    HStack {
                        Image(systemName: page.wrappedSymbol).foregroundColor(Color.accentColor)
                        Image(systemName: "chevron.down")
                            .imageScale(.small)
                            .foregroundColor(Color.secondary)
                    }
                    .onTapGesture { showingIconPicker = true }
                    .sheet(isPresented: $showingIconPicker) {
                        IconPickerView(activeIcon: $page.wrappedSymbol)
                    }
                }
            }
            Section(header: Text("Settings")) {
                HStack {
                    Text("Item Limit")
                    Spacer()
                    Text("\(itemsPerFeedStepperValue)")
                    Stepper(
                        "Item Limit",
                        value: $itemsPerFeedStepperValue,
                        in: 1...Int(Int16.max)
                    ).labelsHidden()
                }

            }

            Section(
                header: HStack {
                    Text("\(page.feedsArray.count) Feeds")
                    Spacer()
                    Text("Drag to Reorder")
                }
            ) {
                ForEach(page.feedsArray) { feed in
                    HStack(alignment: .center, spacing: 12) {
                        feed.feedData?.faviconImage
                            .scaleEffect(1 / UIScreen.main.scale)
                            .frame(width: 16, height: 16, alignment: .center)
                            .clipped()
                        Text(feed.wrappedTitle).padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteFeed)
                .onMove(perform: moveFeed)
            }
        }
        .environment(\.editMode, .constant(.active))
        .onAppear(perform: load)
        .onDisappear(perform: save)
    }

    private func close() {
        presentationMode.wrappedValue.dismiss()
    }

    private func load() {
        itemsPerFeedStepperValue = page.wrappedItemsPerFeed
    }

    private func save() {
        var refresh = false
        if itemsPerFeedStepperValue != page.wrappedItemsPerFeed {
            page.wrappedItemsPerFeed = itemsPerFeedStepperValue
            refresh = true
        }

        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
                if refresh == true {
                    self.refreshManager.refresh(page: page)
                }
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
