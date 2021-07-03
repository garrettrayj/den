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
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager
    
    @ObservedObject var page: Page
    
    @State var itemsPerFeedStepperValue: Int = 0
    @State var pageNameText: String = ""

    var body: some View {
        Form {
            Section(header: Text("\nSettings")) {
                HStack {
                    Text("Name")
                    TextField("Name", text: $pageNameText).multilineTextAlignment(.trailing)
                }
                
                Stepper("Feed Item Limit: \(itemsPerFeedStepperValue)", value: $itemsPerFeedStepperValue, in: 1...Int(Int16.max))
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
                        Text(feed.wrappedTitle)
                    }
                }
                .onDelete(perform: deleteFeed)
                .onMove(perform: moveFeed)
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Page Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadPage)
        .onDisappear(perform: savePage)
    }
    
    private func close() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func loadPage() {
        itemsPerFeedStepperValue = page.wrappedItemsPerFeed
        pageNameText = page.wrappedName
    }
    
    private func savePage() {
        var refresh = false
        
        if itemsPerFeedStepperValue != page.wrappedItemsPerFeed {
            page.wrappedItemsPerFeed = itemsPerFeedStepperValue
            refresh = true
        }
        
        if pageNameText != page.wrappedName {
            page.wrappedName = pageNameText
        }
        
        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
                
                if refresh == true {
                    self.refreshManager.refresh(page)
                }
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
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
