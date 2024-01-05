//
//  PageInspector.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct PageInspector: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page
    
    @Binding var pageLayout: PageLayout

    @State private var showingIconSelector: Bool = false

    var body: some View {
        Form {
            feedsSection
        }
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }

    private var feedsSection: some View {
        Section {
            if page.feedsArray.isEmpty {
                Text("Page Empty", comment: "Page settings feeds empty message.")
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(page.feedsArray) { feed in
                        HStack {
                            FeedTitleLabel(feed: feed)
                            Spacer()
                            #if os(macOS)
                            Image(systemName: "line.3.horizontal")
                                .imageScale(.large)
                                .foregroundStyle(.tertiary)
                            #endif
                        }.padding(.vertical, 4)
                    }
                    .onMove(perform: moveFeed)
                }
            }
        } header: {
            Text("Feeds", comment: "Page settings section header.")
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

        do {
            try viewContext.save()
            page.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
