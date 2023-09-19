//
//  Organizer.swift
//  Den
//
//  Created by Garrett Johnson on 9/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import UniformTypeIdentifiers

struct Organizer: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var showingInspector: Bool

    @State private var selection = Set<Feed>()

    var body: some View {
        List(selection: $selection) {
            ForEach(profile.pagesArray) { page in
                Section {
                    ForEach(page.feedsArray) { feed in
                        HStack {
                            FeedTitleLabel(feed: feed)
                            Spacer()
                            Group {
                                if feed.feedData == nil {
                                    Image(systemName: "circle.slash").foregroundStyle(.yellow)
                                    Text("No Data")
                                } else if let error = feed.feedData?.wrappedError {
                                    Image(systemName: "bolt.horizontal").foregroundStyle(.red)
                                    switch error {
                                    case .parsing:
                                        Text("Parsing Error")
                                    case .request:
                                        Text("Network Error")
                                    }
                                } else if let responseTime = feed.feedData?.responseTime {
                                    if responseTime > 5 {
                                        Image(systemName: "tortoise").foregroundStyle(.brown)
                                    } else if !feed.isSecure {
                                        Image(systemName: "lock.slash").foregroundStyle(.orange)
                                    }
                                    Text("\(Int(responseTime * 1000)) ms")
                                }
                            }
                            .font(.callout)
                            .imageScale(.medium)
                            .foregroundStyle(.secondary)
                        }
                        .tag(feed)
                    }
                    .onMove { indices, newOffset in
                        moveFeeds(page: page, indices: indices, newOffset: newOffset)
                    }
                } header: {
                    Label {
                        page.nameText
                    } icon: {
                        Image(systemName: page.wrappedSymbol)
                    }
                }
            }
        }
        .inspector(isPresented: $showingInspector) {
            OrganizerInspector(profile: profile, selection: $selection)
        }
        #if os(macOS)
        .listStyle(.inset(alternatesRowBackgrounds: true))
        #endif
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        #endif
        .navigationTitle(Text("Organizer", comment: "Navigation title."))
        .toolbar {
            OrganizerToolbar(
                profile: profile,
                selection: $selection,
                showingInspector: $showingInspector
            )
        }
    }

    private func moveFeeds(page: Page, indices: IndexSet, newOffset: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Feed] = page.feedsArray.map { $0 }

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: indices, toOffset: newOffset)

        // Update the userOrder attribute in revisedItems to persist the new order.
        // This is done in reverse to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }

        if viewContext.hasChanges {
            do {
                try viewContext.save()
                profile.objectWillChange.send()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
