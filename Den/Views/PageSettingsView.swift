//
//  PageOrganizerView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 User interface for reordering, moving, and deleting Gadgets within a Page
 */
struct PageSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager
    @ObservedObject var page: Page
    @State var itemsPerFeedStepperValue: Int = 0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    HStack {
                        Text("Title")
                        TextField("Title", text: $page.wrappedName).multilineTextAlignment(.trailing)
                    }
                    
                    Stepper("Feed Item Limit: \(itemsPerFeedStepperValue)", value: $itemsPerFeedStepperValue, in: 1...Int(Int16.max))
                }
                
                Section(header: HStack { Text("\(page.feedsArray.count) Feeds"); Spacer(); Text("Drag to Reorder") }) {
                    List {
                        ForEach(page.feedsArray) { feed in
                            Text(feed.wrappedTitle)
                        }
                        .onDelete(perform: delete)
                        .onMove(perform: move)
                    }
                }
            }
            .navigationTitle("Page Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Close") }
            })
            .environment(\.editMode, .constant(.active))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            itemsPerFeedStepperValue = page.wrappedItemsPerFeed
        }
        .onDisappear {
            if itemsPerFeedStepperValue != page.wrappedItemsPerFeed {
                page.wrappedItemsPerFeed = itemsPerFeedStepperValue
            }
            
            if self.viewContext.hasChanges {
                do {
                    try viewContext.save()
                    
                    DispatchQueue.main.async {
                        refreshManager.refresh(page)
                    }
                    
                } catch let error as NSError {
                    CrashManager.shared.handleCriticalError(error)
                }
            }
        }
    }
    
    func delete(indices: IndexSet) {
        page.feedsArray.delete(at: indices, from: viewContext)
    }
    
    private func move( from source: IndexSet, to destination: Int) {
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
